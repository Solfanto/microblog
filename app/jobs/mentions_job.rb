class MentionsJob < ApplicationJob
  queue_as :low_priority

  def perform(post)
    mentions = post.content&.scan(/\@([a-zA-Z0-9_]+)/).map(&:last).uniq
    mentions.each do |mention|
      user = User.find_by(username: mention)
      Mention.create(user: user, post: post) if user
    end
  end
end
