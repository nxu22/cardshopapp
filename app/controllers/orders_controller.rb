class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :save_user_info, :order_details, :save_order_details, :payment_info, :process_payment, :user_info]
  before_action :set_cart, only: [:order_details, :payment_info, :save_user_info]
  before_action :authenticate_user!, except: [:show, :index]  # Ensuring all order interactions require user authentication except viewing an order if that's permissible.

  # Displays all orders for the logged-in user
  def index
    @orders = current_user.orders.includes(:order_items => :product).order(created_at: :desc)
  end

  def save_user_info
    if @order.update(user_info_params)
      calculate_taxes_and_total
      redirect_to order_details_path(order_id: @order.id)
    else
      flash[:alert] = @order.errors.full_messages.join(", ")
      render :user_info
    end
  end

  def save_order_details
    if @order.update(order_details_params)
      redirect_to payment_info_path(order_id: @order.id)
    else
      render :order_details
    end
  end

  def new
    @order = Order.new
    @cart = session[:cart] || {}
    @products = Product.find(@cart.keys)
    if user_signed_in?
      @order.assign_attributes(
        address_line1: current_user.address_line1,
        city: current_user.city,
        province: current_user.province,
        postal_code: current_user.postal_code,
        country: current_user.country
      )
    end
    calculate_taxes_and_total
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user if user_signed_in?
    @cart = session[:cart] || {}
    @cart.each do |product_id, quantity|
      product = Product.find(product_id)
      @order.order_items.build(product: product, quantity: quantity, price: product.price)
    end
    calculate_taxes_and_total
    if @order.save
      redirect_to payment_info_path(order_id: @order.id)
    else
      handle_new_order_view
      render :new
    end
  rescue StandardError => e
    Rails.logger.error "Error in create action: #{e.message}"
    handle_new_order_view
    render :new, alert: 'There was an error processing your order. Please try again.'
  end

  def process_payment
    if @order.nil?
      flash[:alert] = "Order not found."
      redirect_to cart_path and return
    end
    stripe_token = params[:stripe_token]
    unless stripe_token.present?
      Rails.logger.error "Stripe token is missing"
      flash[:alert] = "Payment could not be processed. Please try again."
      redirect_to payment_info_path(order_id: @order.id) and return
    end
    begin
      charge = Stripe::Charge.create(
        amount: (@order.total_price * 100).to_i,
        currency: 'cad',
        source: stripe_token,
        description: "Order ##{@order.id}"
      )
      Rails.logger.info "Stripe charge created: #{charge.id}"
      @order.update(payment_id: charge.id, status: 'completed')
      session[:cart] = {}
      redirect_to order_path(@order), notice: 'Order was successfully placed!'
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error while processing payment: #{e.message}"
      flash[:error] = "Payment error: #{e.message}"
      redirect_to payment_info_path(order_id: @order.id)
    end
  end

  def user_info
    @order = Order.find_or_initialize_by(id: params[:order_id]) do |order|
      order.user = current_user
      order.assign_attributes(
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        address: current_user.address,
        province_id: current_user.province_id,
        total_price: 0
      )
    end
    unless @order.persisted?
      if @order.save
        Rails.logger.info "New order created: #{@order.inspect}"
      else
        Rails.logger.error "Order creation failed: #{@order.errors.full_messages.join(", ")}"
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
    @cart = current_cart
  end

  def order_params
    params.require(:order).permit(:address_line1, :city, :province, :postal_code, :country, :stripe_token)
  end

  def user_info_params
    params.require(:order).permit(:first_name, :last_name, :email, :address, :province_id)
  end

  def order_details_params
    params.require(:order).permit(:total_price, :PST, :GST, :HST, :qst)
  end

  def calculate_taxes_and_total
    province = @order.province
    pst_rate = province.pst || 0.0
    gst_rate = province.gst || 0.0
    hst_rate = province.hst || 0.0
    qst_rate = province.qst || 0.0
    pst = @cart.cart_items.sum { |item| item.product.price * item.quantity * (pst_rate / 100) }
    gst = @cart.cart_items.sum { |item| item.product.price * item.quantity * (gst_rate / 100) }
    hst = @cart.cart_items.sum { |item| item.product.price * item.quantity * (hst_rate / 100) }
    qst = @cart.cart_items.sum { |item| item.product.price * item.quantity * (qst_rate / 100) }
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity } + pst + gst + hst + qst
    puts "PST: #{pst}, GST: #{gst}, HST: #{hst}, QST: #{qst}, Total Price: #{total_price}" # Debugging output
    @order.update(PST: pst, GST: gst, HST: hst, qst: qst, total_price: total_price)
  end

  def handle_new_order_view
    @order ||= Order.new
    @cart = session[:cart] || {}
    @products = Product.find(@cart.keys)
    calculate_taxes_and_total
  end
end
