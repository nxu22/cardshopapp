class ProductsController < ApplicationController
  def index
    @products = Product.all
    @user = current_user
    
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
      @products = @products.where('lower(name) LIKE ?', query)
    end

    if params[:filter].present?
      case params[:filter]
      when 'on_sale'
        @products = @products.where(on_sale: true)
      when 'new'
        @products = @products.where('created_at >= ?', 3.days.ago)
      when 'recently_updated'
        @products = @products.where('updated_at >= ?', 3.days.ago)
      end
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end
