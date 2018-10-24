class Follow < ApplicationRecord
  belongs_to :user, counter_cache: 'following_count'
  belongs_to :following, class_name: 'User', counter_cache: 'followers_count'
  
  after_commit :send_notifications, on: :create
  
  protected
  
  def send_notifications
    NotificationsJob.perform_later(self)
  end
end
