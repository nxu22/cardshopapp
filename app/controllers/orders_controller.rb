class OrdersController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :require_user # Ensure user is logged in

  def new
    @order = Order.new
  end

  def create
    @order = current_user.orders.build(order_params)
    @order.total_price = calculate_total_price
    province = current_user.province
    @order.pst = calculate_pst(province)
    @order.gst = calculate_gst(province)
    @order.hst = calculate_hst(province)
    @order.qst = calculate_qst(province) if province.name == 'Quebec'

    if @order.save
      move_cart_items_to_order(@order)
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
    params.require(:order).permit(:payment_method)
  end

  def set_cart
    @cart = current_cart
  end

  def calculate_total_price
    @cart.cart_items.sum { |item| item.product.price * item.quantity }
  end

  def calculate_pst(province)
    province.pst
  end

  def calculate_gst(province)
    province.gst
  end

  def calculate_hst(province)
    province.hst
  end

  def calculate_qst(province)
    province.qst
  end

  def move_cart_items_to_order(order)
    @cart.cart_items.each do |item|
      order.order_items.create(product: item.product, quantity: item.quantity, price: item.product.price)
      item.destroy
    end
  end
end
