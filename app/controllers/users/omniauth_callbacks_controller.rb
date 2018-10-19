class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    define_method("#{provider}") do
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
      else
        if provider == :facebook
          session["devise.#{provider}_data"] = request.env["omniauth.auth"]
        elsif provider == :twitter
          session["devise.#{provider}_data"] = { "provider" => request.env["omniauth.auth"].provider, "uid" => request.env["omniauth.auth"].uid, "info" => { "name" => request.env["omniauth.auth"].extra.raw_info.name, "email" => request.env["omniauth.auth"].info.email } }
        elsif provider == :solfanto_oauth2
          session["devise.#{provider}_data"] = request.env["omniauth.auth"]
        end
        redirect_to new_user_registration_url, flash: { error: @user.errors.full_messages.to_sentence }
      end
    end
  end
  
  [:solfanto_oauth2, :facebook, :twitter].each do |provider|
    provides_callback_for provider
  end

  def failure
    redirect_to root_path, flash: { error: "Authentication failed." }
  end
end