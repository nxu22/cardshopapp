class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :save_user_info, :order_details, :save_order_details, :process_payment, :user_info]
  before_action :set_cart, only: [:order_details, :save_user_info, :process_payment]
  before_action :authenticate_user!, except: [:show, :index]

  def index
    @orders = current_user.orders.includes(order_items: :product)
  end

  def save_user_info
    # Extract stripe_token from the nested order params
    stripe_token = params[:order].delete(:stripe_token)
  
    if @order.update(user_info_params)
      if stripe_token.present?
        process_payment(stripe_token)
      else
        flash[:alert] = 'Stripe token is missing. Please try again.'
        render :user_info
      end
    else
      flash[:alert] = @order.errors.full_messages.join(", ")
      render :user_info
    end
  end
  

  def save_order_details
    if @order.update(order_details_params)
      redirect_to user_info_path(order_id: @order.id)
    else
      render :order_details
    end
  end

  def new
    @order = Order.new
    @cart = session[:cart] || {}
    @products = Product.find(@cart.keys)
    assign_user_address_to_order if user_signed_in?
    update_order_totals
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user if user_signed_in?
    add_cart_items_to_order
    update_order_totals

    stripe_token = params.delete(:stripe_token)
    if @order.save
      if stripe_token.present?
        process_payment(stripe_token)
      else
        flash[:alert] = 'Stripe token is missing. Please try again.'
        render :new
      end
    else
      handle_new_order_view
      flash[:alert] = @order.errors.full_messages.join(", ")
      render :new
    end
  rescue StandardError => e
    Rails.logger.error "Order creation failed: #{e.message}"
    flash[:alert] = "Could not create order. Please try again."
    render :new
  end

  def process_payment(stripe_token)
    Rails.logger.info "Processing payment with token: #{stripe_token}"
  
    if stripe_token.blank?
      flash[:alert] = 'Stripe token is missing. Please try again.'
      redirect_to user_info_path(order_id: @order.id) and return
    end
  
    update_order_totals
  
    if @order.total_price < 0.50
      flash[:alert] = 'The total amount must be at least $0.50 CAD. Please add more items to your cart.'
      render :user_info and return
    end
  
    begin
      charge = Stripe::Charge.create(
        amount: (@order.total_price * 100).to_i,
        currency: 'cad',
        source: stripe_token,
        description: "Order ##{@order.id}"
      )
  
      Rails.logger.info "Stripe charge created: #{charge.id}"
      if charge.paid
        @order.update(payment_id: charge.id, status: 'completed') # Ensure these fields are updated here
        session[:cart] = {}  # Clear the cart after successful payment
        redirect_to root_path, notice: 'Order was successfully placed!' and return
      else
        Rails.logger.error "Payment failed for Order ##{@order.id}"
        flash[:alert] = 'There was an issue with your payment. Please try again.'
        render :user_info and return
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error while processing payment: #{e.message}"
      flash[:alert] = 'There was an error processing your payment. Please try again.'
      render :user_info and return
    end
  end  

  def user_info
    @order = Order.find_or_initialize_by(id: params[:order_id]) do |order|
      order.user = current_user
      assign_user_address_to_order
      order.total_price = 0
    end

    unless @order.persisted?
      if @order.save
        Rails.logger.info "New order created: #{@order.inspect}"
        redirect_to user_info_path(order_id: @order.id)
      else
        Rails.logger.error "Order creation failed: #{@order.errors.full_messages.join(', ')}"
        redirect_to cart_path, alert: "Could not create order. Please try again."
      end
    end
  end

  def show
    unless @order
      flash[:alert] = "Order not found."
      redirect_to cart_path
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:order_id])
    unless @order
      Rails.logger.error "Order not found for id: #{params[:order_id]}"
      flash[:alert] = "Order not found."
      redirect_to cart_path and return
    end
  end

  def set_cart
    @cart = current_user.shopping_cart || ShoppingCart.create(user: current_user)
  end

  def order_params
    params.require(:order).permit(:address_line1, :city, :province, :postal_code, :country, :PST, :GST, :HST, :qst)
  end

  def user_info_params
    params.require(:order).permit(:first_name, :last_name, :email, :address, :province_id)
  end

  def order_details_params
    params.require(:order).permit(:total_price, :PST, :GST, :HST, :qst)
  end

  def update_order_totals(amount = nil)
    @total_amount = amount || calculate_order_total

    if @order.province.present?
      # Use the TaxCalculator module to calculate the taxes and total price
      @gst, @pst, @hst, @qst, @total_with_taxes = TaxCalculator.calculate_tax(@total_amount, @order.province)
      @order.update(total_price: @total_with_taxes, PST: @pst, GST: @gst, HST: @hst, qst: @qst)
    else
      Rails.logger.error "Province not found for Order ##{@order.id}"
      flash[:alert] = "Province information is missing. Please ensure you have selected a province."
      redirect_to user_info_path(order_id: @order.id) and return
    end
  end

  def calculate_order_total
    @cart.cart_items.sum { |item| item.product.price * item.quantity }
  end

  def assign_user_address_to_order
    @order.assign_attributes(
      address_line1: current_user.address_line1,
      city: current_user.city,
      province: current_user.province,
      postal_code: current_user.postal_code,
      country: current_user.country
    )
  end

  def add_cart_items_to_order
    @cart.cart_items.each do |cart_item|
      @order.order_items.build(product: cart_item.product, quantity: cart_item.quantity, price: cart_item.product.price)
    end
  end

  def handle_new_order_view
    @order ||= Order.new
    @cart = session[:cart] || {}
    @products = Product.find(@cart.keys)
    update_order_totals
  end
end
