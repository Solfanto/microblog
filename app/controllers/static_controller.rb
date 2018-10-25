class StaticController < ApplicationController
  def about
  end
  
  def letsencrypt
    if Rails.application.credentials[Rails.env.to_sym][:letsencrypt_acme_challenge].keys.map(&:to_s).include?(params[:id])
      render plain: params[:id] + "." + Rails.application.credentials[Rails.env.to_sym][:letsencrypt_acme_challenge][params[:id].to_sym]
    else
      render plain: nil
    end
  end
end
