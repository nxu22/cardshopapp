class CartsController < ApplicationController
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
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
