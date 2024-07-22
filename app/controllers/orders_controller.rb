class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :save_user_info, :order_details, :save_order_details, :payment_info, :process_payment]
  before_action :set_cart, only: [:order_details, :payment_info, :save_user_info]

  def show
    # `@order` 已经通过 `before_action` 设置
  end

  def user_info 
    if params[:order_id]
      @order = Order.find(params[:order_id])
    else
      @order = Order.create(user: current_user)
    end
  end

  def save_user_info
    set_cart  # 确保 @cart 在调用 calculate_taxes_and_total 之前被设置
    if @order.update(user_info_params)
      calculate_taxes_and_total
      redirect_to order_details_path(order_id: @order.id)
    else
      puts "Order update failed: #{@order.errors.full_messages.join(', ')}"
      flash[:alert] = @order.errors.full_messages.join(", ")
      render :user_info
    end
  end

  def order_details
    # `@cart` 现在由 `set_cart` before_action 设置
  end

  def save_order_details
    if @order.update(order_details_params)
      redirect_to payment_info_path(order_id: @order.id)
    else
      render :order_details
    end
  end

  def payment_info
    # `@cart` 现在由 `set_cart` before_action 设置
  end

  def process_payment
    if @order.update(payment_params)
      @order.update(status: 'paid')
      redirect_to order_path(@order)
    else
      render :payment_info
    end
  end

  private

  def set_order
    @order = Order.find(params[:id] || params[:order_id])
  end

  def set_cart
    @cart = current_cart
  end

  def user_info_params
    params.require(:order).permit(:first_name, :last_name, :email, :address, :province_id)
  end

  def order_details_params
    params.require(:order).permit(:total_price, :PST, :GST, :HST, :qst)
  end

  def payment_params
    params.require(:order).permit(:payment_id)
  end

  def calculate_taxes_and_total
    province = @order.province
  
    pst_rate = province.pst_rate || 0
    gst_rate = province.gst_rate || 0
    hst_rate = province.hst_rate || 0
    qst_rate = province.qst_rate || 0
  
    pst = @cart.cart_items.sum { |item| item.product.price * pst_rate }
    gst = @cart.cart_items.sum { |item| item.product.price * gst_rate }
    hst = @cart.cart_items.sum { |item| item.product.price * hst_rate }
    qst = @cart.cart_items.sum { |item| item.product.price * qst_rate }
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity } + pst + gst + hst + qst
  
    puts "PST: #{pst}, GST: #{gst}, HST: #{hst}, QST: #{qst}, Total Price: #{total_price}"  # 调试输出
  
    @order.update(PST: pst, GST: gst, HST: hst, qst: qst, total_price: total_price)
  end
end
