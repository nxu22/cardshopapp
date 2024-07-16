class OrdersController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :require_user

  def new
    @order = Order.new
    @pst, @gst, @hst, @qst, @total_tax = calculate_tax
    @total_price = calculate_total_price
  end

  def create
    @order = current_user.orders.build(order_params)
    province = current_user.province
    @order.pst = calculate_pst(province)
    @order.gst = calculate_gst(province)
    @order.hst = calculate_hst(province)
    @order.qst = calculate_qst(province) if province.name == 'Quebec'
    @order.total_price = calculate_total_price

    if @order.save
      move_cart_items_to_order(@order)
      # Here you would integrate with a payment processor like Stripe or PayPal
      # Assuming payment is successful, you would then redirect to the show action
      redirect_to order_path(@order), notice: 'Order was successfully created.'
    else
      render :new
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:payment_method, :payment_details)
  end

  def set_cart
    @cart = current_cart
  end

  def calculate_tax
    province = current_user.province
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    pst = total_price * province.pst / 100
    gst = total_price * province.gst / 100
    hst = total_price * province.hst / 100
    qst = province.name == 'Quebec' ? total_price * province.qst / 100 : 0
    total_tax = pst + gst + hst + qst
    return pst, gst, hst, qst, total_tax
  end

  def calculate_total_price
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    total_price + @total_tax
  end

  def calculate_pst(province)
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    total_price * province.pst / 100
  end

  def calculate_gst(province)
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    total_price * province.gst / 100
  end

  def calculate_hst(province)
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    total_price * province.hst / 100
  end

  def calculate_qst(province)
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    province.name == 'Quebec' ? total_price * province.qst / 100 : 0
  end

  def move_cart_items_to_order(order)
    @cart.cart_items.each do |item|
      order.order_items.create(product: item.product, quantity: item.quantity, price: item.product.price)
      item.destroy
    end
  end
end
