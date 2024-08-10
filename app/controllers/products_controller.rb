class ProductsController < ApplicationController
  before_action only: [:index, :show]
  def index
    @user = current_user
    @categories = Category.all  # Load all categories

    # Start with all products or category-specific products
    if params[:category].present?
      @category = Category.find_by(name: params[:category])
      if @category
        @products = @category.products.page(params[:page]).per(10)
      else
        @products = Product.none  # Ensures pagination methods still work
        flash[:alert] = "Category not found"
      end
    else
      @products = Product.all
    end

    # Apply keyword search to either all products or category-specific products
    if params[:query].present?
      query = "%#{params[:query].downcase}%"
      @products = @products.where('lower(name) LIKE ?', query)
    end

    # Apply additional filters before pagination
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

    @products = @products.order(:created_at).page(params[:page]).per(10)  # Ensure pagination is always applied
  end

  def show
    @product = Product.find(params[:id])
  end
end
