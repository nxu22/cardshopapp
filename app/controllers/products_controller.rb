  class ProductsController < ApplicationController
    def index
      @user = current_user
      @categories = Category.all  # 加载所有分类

      # Set a default scope to handle pagination
      @products = Product.order(:created_at).page(params[:page]).per(10)

      if params[:category]
        @category = Category.find_by(name: params[:category])
        if @category
          # Apply category filter before pagination
          @products = @category.products.page(params[:page]).per(10)
        else
          @products = Product.none  # Ensures pagination methods still work
          flash[:alert] = "Category not found"
        end
      elsif params[:query].present?
        # Apply search filter before pagination
        query = "%#{params[:query].downcase}%"
        @products = @products.where('lower(name) LIKE ?', query)
      end

      if params[:filter].present?
        # Apply additional filters before pagination
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

    private

    def current_user
      if session[:user_id]
        begin
          @current_user ||= User.find(session[:user_id])
        rescue ActiveRecord::RecordNotFound
          session[:user_id] = nil
          @current_user = nil
        end
      else
        @current_user = nil
      end
    end
  end
