class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?, :current_cart

  private

  # Method to get the current user based on the session user_id
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # Method to check if the user is logged in
  def logged_in?
    !!current_user
  end

  # Method to check if the current user is an admin
  def admin?
    current_user && current_user.admin?
  end

  # Method to ensure a user is logged in
  def require_user
    redirect_to login_path unless logged_in?
  end

  # Method to ensure the current user is an admin
  def require_admin
    redirect_to root_path unless admin?
  end

  # Method to get or create the current shopping cart
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
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_root_path # Redirect to ActiveAdmin dashboard
    else
      super # Redirect to the default path for non-admin users
    end
  end
end
