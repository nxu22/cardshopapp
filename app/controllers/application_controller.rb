# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
    helper_method :current_user, :logged_in?, :admin?
  
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
  end
  