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

  private

  def set_cart
    @cart = current_cart
  end
end
