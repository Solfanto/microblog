class NotificationsJob < ApplicationJob
  queue_as :low_priority

  def perform(item)
    case item
    when Post
      if item.repost && item.original_user_id
        item.original_user.notifications.create(notification_type: :reposted, primary_item: item, secondary_item: item.user, message: "<b>#{ERB::Util.html_escape(item.display_name)}</b> reposted your post: \"#{ERB::Util.html_escape(item.original_post.content)}\".")
      elsif item.original_post_id && item.original_user_id
        item.original_user.notifications.create(notification_type: :replied, primary_item: item, secondary_item: item.user, message: "<b>#{ERB::Util.html_escape(item.display_name)}</b> replied to your post: \"#{ERB::Util.html_escape(item.original_post.content)}\".")
      end
    when Follow
      if item.following.follow?(item.user)
        item.following.notifications.create(notification_type: :followed_back, primary_item: item.user, message: "<b>#{ERB::Util.html_escape(item.user.display_name)}</b> followed you back.")
      else
        item.following.notifications.create(notification_type: :followed, primary_item: item.user, message: "<b>#{ERB::Util.html_escape(item.user.display_name)}</b> followed you.")
      end
    when Like
      item.post.user.notifications.create(notification_type: :liked, primary_item: item.post, secondary_item: item.user, message: "<b>#{ERB::Util.html_escape(item.user.display_name)}</b> liked your post: \"#{ERB::Util.html_escape(item.post.content)}\".")
    when Mention
      item.user.notifications.create(notification_type: :mentioned, primary_item: item.post, secondary_item: item.post.user, message: "<b>#{ERB::Util.html_escape(item.post.display_name)}</b> mentioned you in their post: \"#{ERB::Util.html_escape(item.post.content)}\".")
    end
  end
end
