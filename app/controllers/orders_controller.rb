class OrdersController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :require_user

  def new
    @order = Order.new
    @user = current_user
    @pst, @gst, @hst, @qst, @total_tax = calculate_tax
    @total_price = calculate_total_price(@total_tax)
  end

  def create
    @order = current_user.orders.build(order_params)
    province = current_user.province
    @order.PST = calculate_pst(province)
    @order.GST = calculate_gst(province)
    @order.HST = calculate_hst(province)
    @order.qst = calculate_qst(province) if province.name == 'Quebec'
    @total_tax = calculate_total_tax(@order.PST, @order.GST, @order.HST, @order.qst)
    @order.total_price = calculate_total_price(@total_tax)

    if params[:order][:stripeToken]
      begin
        charge = Stripe::Charge.create(
          amount: (@order.total_price * 100).to_i, # Amount in cents
          currency: 'usd',
          description: 'Order payment',
          source: params[:order][:stripeToken]
        )

        @order.payment_id = charge.id
        @order.status = 'paid' # Use status instead of payment_status
      rescue Stripe::CardError => e
        flash[:error] = e.message
        render :new and return
      end
    end

    if @order.save
      move_cart_items_to_order(@order)
      redirect_to @order, notice: '订单创建成功。'
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

  def calculate_total_price(total_tax)
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    total_price + total_tax
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

  def calculate_total_tax(pst, gst, hst, qst)
    pst ||= 0
    gst ||= 0
    hst ||= 0
    qst ||= 0
    pst + gst + hst + qst
  end

  def move_cart_items_to_order(order)
    @cart.cart_items.each do |item|
      order.order_items.create(product: item.product, quantity: item.quantity, price: item.product.price)
      item.destroy
    end
  end
end
