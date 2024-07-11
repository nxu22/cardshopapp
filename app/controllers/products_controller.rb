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
    elsif params[:query].present?
      query = "%#{params[:query].downcase}%"
      @products = Product.where('lower(name) LIKE ?', query)
    else
      @products = Product.all
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end
