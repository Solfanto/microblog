class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :primary_item, polymorphic: true, optional: true
  belongs_to :secondary_item, polymorphic: true, optional: true
  
  after_commit :update_unread_count, on: [:create, :update, :destroy]
  
  def update_unread_count
    return if self.user.nil?
    self.user.unread_notifications_count = self.user.notifications.where(read_at: nil).count
    self.user.save
  end
end
