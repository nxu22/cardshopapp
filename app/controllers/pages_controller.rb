# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def show
    case params[:page_type]
    when 'about'
      render :about
    when 'contact'
      render :contact
    else
      render :not_found, status: :not_found
    end
  end
end
