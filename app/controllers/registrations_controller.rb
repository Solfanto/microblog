class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  
  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:display_name, :bio, :website, :city])
  end
end
