class OrdersController < ApplicationController
  before_action :set_order, only: [:save_user_info, :order_details, :save_order_details, :payment_info, :process_payment]

  def user_info
    if params[:order_id]
      @order = Order.find(params[:order_id])
    else
      @order = Order.create(user: current_user)
    end
  end

  def save_user_info
    if @order.update(user_info_params)
      redirect_to order_details_path(order_id: @order.id)
    else
      puts "Order update failed: #{@order.errors.full_messages.join(', ')}"
      flash[:alert] = @order.errors.full_messages.join(", ")
      render :user_info
    end
  end

  def order_details
    @order = Order.find(params[:order_id])
  end

  def save_order_details
    @order.require_payment_and_status = true if @order.respond_to?(:require_payment_and_status=)
    if @order.update(order_details_params)
      redirect_to payment_info_path(order_id: @order.id)
    else
      render :order_details
    end
  end

  def payment_info
    @order = Order.find(params[:order_id])
  end

  def process_payment
    @order.require_payment_and_status = true if @order.respond_to?(:require_payment_and_status=)
    if @order.update(payment_params)
      @order.update(status: 'paid')
      redirect_to order_path(@order)
    else
      render :payment_info
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
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
end
