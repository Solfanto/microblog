class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
  
  validates :post, uniqueness: { scope: :user }
  
  after_commit :send_notifications, on: :create
  
  protected
  
  def send_notifications
    NotificationsJob.perform_later(self)
  end
end
