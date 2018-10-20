class Follow < ApplicationRecord
  belongs_to :user, counter_cache: 'following_count'
  belongs_to :following, class_name: 'User', counter_cache: 'followers_count'
end
