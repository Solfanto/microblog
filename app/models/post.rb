class Post < ApplicationRecord
  belongs_to :user, optional: true, counter_cache: true
  
  before_create :set_user_info
  
  def set_user_info
    self.username = self.user.username
    self.display_name = self.user.display_name
  end
end
