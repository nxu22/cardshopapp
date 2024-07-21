class CartsController < ApplicationController
  before_action :set_cart
  before_action :require_user, only: [:checkout]

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  def checkout
    @order = Order.new(user: current_user)
    if @order.save(validate: false)
      puts "Created Order ID: #{@order.id}"  # 日志输出
      redirect_to user_info_path(order_id: @order.id)
    else
      puts "Order creation failed: #{@order.errors.full_messages.join(', ')}"
      redirect_to cart_path, alert: "Order creation failed."
    end
  end
  
  def add_item
    product = Product.find(params[:product_id])
    @cart.add_product(product)
    redirect_to cart_path, notice: 'Product added to cart.'
  end

  def remove_item
    product = Product.find(params[:product_id])
    @cart.remove_product(product)
    redirect_to cart_path, notice: 'Product removed from cart.'
  end

  def update
    product_id = params[:product_id]
    quantity = params[:quantity][product_id].to_i

    cart_item = @cart.cart_items.find_by(product_id: product_id)
    if cart_item
      cart_item.update(quantity: quantity)
    end

    redirect_to cart_path, notice: 'Cart updated successfully.'
  end

  private

  def set_cart
    @cart = current_cart
  end
end
