class Post < ApplicationRecord
  belongs_to :user, optional: true, counter_cache: true
  belongs_to :original_user, class_name: 'User', optional: true
  belongs_to :original_post, class_name: 'Post', optional: true
  belongs_to :post_thread
  has_many :replies, class_name: 'Post', foreign_key: :original_post
  has_many :posts
  has_many_attached :attachments
  
  before_validation :set_user_info, on: :create
  before_validation :set_post_thread, on: :create
  after_commit :send_notifications, on: :create
  after_commit :update_post_thread, on: :create
  after_commit :detect_mentions, on: :create
  
  include PgSearch
  pg_search_scope :search, against: [:content], using: {tsearch: {dictionary: "english"}}, ignoring: :accents
  
  validates :username, presence: true
  validates :display_name, presence: true
  validates :content, presence: true, unless: :repost?
  validate :cannot_repost_self
  validates :attachments, blob: { content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg', 'image/webp', 'video/mp4', 'video/webm', 'video/ogg'], size_range: 0..25.megabytes }
  validates :original_user, presence: true, if: :repost?
  validates :original_post, presence: true, if: :repost?
  
  attr_accessor :current
  
  def self.text_search(query)
    if query.present?
      search(query)
    else
      self.where(nil)
    end
  end
  
  def as_json(options={})
    {
      id: self.id,
      userId: self.user_id,
      username: self.username,
      displayName: self.display_name,
      profilePicture: (Rails.application.routes.url_helpers.url_for(self.user.squared_profile_picture(50)) if self.user&.profile_picture&.attached? && self.user&.profile_picture&.variable?) || nil,
      likesCount: self.likes_count,
      repostsCount: self.reposts_count,
      private: self.private,
      repost: self.repost,
      content: self.content,
      createdAt: self.created_at.httpdate,
      current: self.current,
      attachments: self.attachments.map { |attachment|
        {
          previewUrl: (Rails.application.routes.url_helpers.url_for(attachment.preview(resize: "200x200>")) if attachment.previewable?) || (Rails.application.routes.url_helpers.url_for(attachment.variant(resize: "200x200")) if attachment.variable?),
          url: Rails.application.routes.url_helpers.url_for(attachment)
        }
      }
    }
  end
  
  def tree
    t = self.post_thread.tree
    path = t.search({"id" => self.id})
    t.dig(*path)&.store("current", true) unless path.nil?
    t
  end
  
  # TODO: requires pagination
  # array of Posts
  def full_thread
    t = self.post_thread.tree
    t.nested_values("id").map{|id|
      p = Post.find(id)
      p.current = true if id == self.id || id == self.original_post_id && self.repost? && self.content.blank?
      p
    }
  end
  
  def cannot_repost_self
    if self.repost? && self.user_id == self.original_user_id
      errors.add(:user, "can't repost oneself")
    end
  end
  
  protected
  
  def set_user_info
    self.username = self.user.username
    self.display_name = self.user.display_name
  end
  
  def set_post_thread
    if self.original_post_id
      self.post_thread_id = self.original_post.post_thread_id
    else
      self.post_thread = PostThread.create
    end
  end
  
  def update_post_thread
    return if self.content.blank?
    t = self.post_thread.tree
    if self.original_post_id
      result = t.search("id" => self.original_post_id)
      unless result[:path].empty?
        t.dig(*result[:path])["replies"].push({"id" => self.id, "replies" => []})
      else
        t["replies"].push({"id" => self.id, "replies" => []})
      end
    else
      t = {"id" => self.id, "replies" => []}
    end
    self.post_thread.tree = t
    self.post_thread.save
  end
  
  def detect_mentions
    MentionsJob.perform_later(self)
  end
  
  def send_notifications
    NotificationsJob.perform_later(self)
  end
end
