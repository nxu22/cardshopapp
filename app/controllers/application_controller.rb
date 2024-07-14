class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?, :current_cart

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def admin?
    current_user && current_user.admin?
  end

  def require_user
    redirect_to login_path unless logged_in?
  end

  def require_admin
    redirect_to root_path unless admin?
  end

  def current_cart
    if logged_in?
      @current_cart ||= ShoppingCart.find_or_create_by(user_id: current_user.id)
    else
      @current_cart ||= ShoppingCart.find(session[:cart_id]) if session[:cart_id]
      @current_cart ||= ShoppingCart.create
      session[:cart_id] = @current_cart.id
      @current_cart
    end
  end
end
