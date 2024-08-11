class PagesController < ApplicationController
  def contact
    @contact_page = ContactPage.first
  end

  def about
    @about_page = AboutPage.first
  end
end