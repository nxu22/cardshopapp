class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    logger.debug "User found: #{user.inspect}"

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      logger.debug "User authenticated: #{user.id}"
      redirect_to products_path, notice: "Welcome, #{user.username}!"
    else
      @error_message = 'Incorrect email or password.'
      logger.debug "Authentication failed for email: #{params[:email]}"
      render :new
    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Logged out successfully.'
  end
end
