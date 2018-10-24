class Mention < ApplicationRecord
  belongs_to :post
  belongs_to :user
  
  after_commit :send_notifications, on: :create
  
  protected
  
  def send_notifications
    NotificationsJob.perform_later(self)
  end
end
