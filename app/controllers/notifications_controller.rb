class NotificationsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  
  def index
    @notifications = current_user.notifications.order('created_at DESC').page(params[:page]).per(25)
  end
  
  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.read_at = Time.now
    @notification.save
    
    case @notification.notification_type.to_sym
    when :followed, :followed_back
      redirect_to user_path(@notification.primary_item.username)
    when :replied, :reposted, :liked, :mentioned
      redirect_to post_path(@notification.primary_item)
    else
      redirect_to root_path, flash: { error: "Notification not found." }
    end
  end
end
