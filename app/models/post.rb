class Post < ApplicationRecord
  belongs_to :user, optional: true, counter_cache: true
  
  before_create :set_user_info
  
  include PgSearch
  pg_search_scope :search, against: [:content], using: {tsearch: {dictionary: "english"}}, ignoring: :accents
  
  def self.text_search(query)
    if query.present?
      search(query)
    else
      self.where(nil)
    end
  end
  
  def set_user_info
    self.username = self.user.username
    self.display_name = self.user.display_name
  end
end
