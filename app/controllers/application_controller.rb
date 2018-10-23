class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  
  before_action :change_default_username
  
  def change_default_username
    if current_user && current_user.is_default_username? && (params[:controller] != "registrations" && params[:action] != "edit" && params[:controller] !~ /devise/)
      redirect_to edit_user_registration_url
    end
  end
end
