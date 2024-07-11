# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  def index
    if params[:category]
      @category = Category.find_by(name: params[:category])
      if @category
        @products = @category.products
      else
        @products = Product.none
        flash[:alert] = "Category not found"
      end
    else
      @products = Product.all
    end
  end
end
