class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :save_user_info, :order_details, :save_order_details, :payment_info, :process_payment]
  before_action :set_cart, only: [:order_details, :payment_info, :save_user_info]
  before_action :authenticate_user!, only: [:new, :create]

  def new
    @order = Order.new
    @cart = session[:cart] || {}
    @products = Product.find(@cart.keys)

    if user_signed_in?
      @order.address_line1 = current_user.address_line1
      @order.city = current_user.city
      @order.province = current_user.province
      @order.postal_code = current_user.postal_code
      @order.country = current_user.country
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
      stripe_token = params[:order][:stripe_token]
      Rails.logger.info "Stripe token received in controller: #{stripe_token}" # Log the token
  
      unless stripe_token.present?
        Rails.logger.error "Stripe token is missing"
        flash[:alert] = "Payment could not be processed. Please try again."
        render :payment_info and return
      end
  
      process_payment(stripe_token) # Pass the token here
      @order.create_invoice
      session[:cart] = {}
      redirect_to user_invoices_path, notice: 'Order was successfully placed!'
    else
      handle_new_order_view
      render :new
    end
  rescue StandardError => e
    Rails.logger.error "Error in create action: #{e.message}"
    handle_new_order_view
    render :new, alert: 'There was an error processing your order. Please try again.'
  end
  
  

  def show
    # `@order` is already set by the `before_action`
  end

  def user_info
    if params[:order_id]
      @order = Order.find(params[:order_id])
    else
      @order = Order.create(user: current_user)
    end
  end

  def save_user_info
    set_cart
    if @order.update(user_info_params)
      calculate_taxes_and_total
      redirect_to order_details_path(order_id: @order.id)
    else
      flash[:alert] = @order.errors.full_messages.join(", ")
      render :user_info
    end
  end

  def order_details
    # `@cart` is now set by the `set_cart` before_action
  end

  def save_order_details
    if @order.update(order_details_params)
      redirect_to payment_info_path(order_id: @order.id)
    else
      render :order_details
    end
  end

  def payment_info
    # `@cart` is now set by the `set_cart` before_action
  end

  def process_payment(stripe_token)
    charge = Stripe::Charge.create(
      amount: (@order.total_price * 100).to_i,
      currency: 'cad',
      source: stripe_token,
      description: "Order ##{@order.id}"
    )
    Rails.logger.info "Stripe charge created: #{charge.id}"
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error while processing payment: #{e.message}"
    flash[:error] = "Payment error: #{e.message}"
    redirect_to payment_info_path(order_id: @order.id)
  end  
  
  private

  def set_order
    @order = Order.find(params[:id] || params[:order_id])
  end

  def set_cart
    @cart = current_cart
  end

  def order_params
    params.require(:order).permit(:address_line1, :city, :province, :postal_code, :country)
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
