class ProductsController < ApplicationController
  def index
    @products = Product.all
    @birthday_products = Product.joins(:category).where(categories: { name: 'Birthday card' })
    @christmas_products = Product.joins(:category).where(categories: { name: 'Christmas card' })
    @thanksgiving_products = Product.joins(:category).where(categories: { name: 'Thanksgiving card' })
    @valentine_products = Product.joins(:category).where(categories: { name: 'Valentine card' })
  end

  def show
    @product = Product.find(params[:id])
  end
end
