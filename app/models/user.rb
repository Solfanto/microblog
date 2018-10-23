require_relative '../../lib/mini_magick/helper'

class User < ApplicationRecord
  extend Memoist
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable, :omniauthable, omniauth_providers: %i[solfanto_oauth2]
  
  validates :provider, presence: true
  
  has_many :posts, dependent: :nullify
  has_many :likes
  has_many :follows
  has_many :followings, class_name: 'User', through: :follows
  has_many :follow_backs, class_name: 'Follow', foreign_key: :following
  has_many :followers, class_name: 'User', through: :follow_backs, source: :user
  has_many :likes
  has_many :liked_posts, class_name: 'Post', through: :likes, source: :post
  has_one_attached :profile_picture
  
  before_validation :set_tmp_username, on: :create
  
  validates :username, format: { with: /\A[a-zA-Z0-9_]+\Z/ }
  validates :display_name, presence: true
  
  def private_timeline_posts
    @private_timeline_posts ||= Post.where(user: [self] + self.followings).order('created_at DESC')
  end
  
  def public_timeline_posts
    @public_timeline_posts ||= Post.where(user: self).order('created_at DESC')
  end
         
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email if user.email.blank?
      user.password = Devise.friendly_token[0,20] if user.password.blank?
      # user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      elsif data = session["devise.twitter_data"] && session["devise.twitter_data"]["info"]
        user.email = data["info"]["email"] if user.email.blank?
      elsif data = session["devise.solfanto_oauth2_data"]
        user.email = data["info"]["email"] if user.email.blank?
      end
    end
  end
  
  def follow?(user_params)
    user_id = user_id_from_params(user_params)
    return nil if user_id.nil?
    
    Follow.where(user_id: self.id, following_id: user_id).count > 0
  end
  memoize :follow?
  
  def follow(user_params)
    user_id = user_id_from_params(user_params)
    return nil if user_id.nil?
    
    return nil if self.follow?(user_id)
    follow = Follow.new(user_id: self.id, following_id: user_id)
    follow_back = Follow.where(user_id: user_id, following_id: self.id).first
    if follow_back
      follow_back.friend = true
      follow.friend = true
    end
    ApplicationRecord.transaction do
      follow_back.save if follow_back
      follow.save
    end
    { follow: follow, follow_back: follow_back }
  end
  
  def unfollow(user_params)
    user_id = user_id_from_params(user_params)
    return nil if user_id.nil?

    follow = Follow.where(user_id: self.id, following_id: user_id).first
    return nil if follow.nil?
    follow_back = Follow.where(user_id: user_id, following_id: self.id).first
    if follow_back
      follow_back.friend = false
      follow.friend = false
    end
    ApplicationRecord.transaction do
      follow_back.save if follow_back
      follow.destroy
    end
    { follow: follow, follow_back: follow_back }
  end
  
  def friend_with?(user)
    self.follows.where(following: user).first&.friend == true
  end
  memoize :friend_with?
  
  def like(post_params)
    post_id = post_id_from_params(post_params)
    return if post_id.nil?
    
    Like.create(user_id: self.id, post_id: post_id)
  end
  
  def unlike(post_params)
    post_id = post_id_from_params(post_params)
    return if post_id.nil?
    
    Like.where(user_id: self.id, post_id: post_id).destroy_all
  end
  
  def like?(post_params)
    post_id = post_id_from_params(post_params)
    return false if post_id.nil?
    
    Like.where(user_id: self.id, post_id: post_id).count > 0
  end
  memoize :like?
  
  def squared_profile_picture(size)
    variation = ActiveStorage::Variation.new(MiniMagickHelper.resize_to_fill(width: size, height: size, blob: profile_picture.blob))
    ActiveStorage::Variant.new(profile_picture.blob, variation)
  end
  
  private
  def set_tmp_username
    o = (['0'..'9'] + ['a'..'z']).map { |i| i.to_a }.flatten
    tmp_username = (0...16).map { o[rand(o.length)] }.join
    loop do
      self.username ||= tmp_username
      self.display_name ||= tmp_username
      break if User.where(username: tmp_username).count == 0
    end
  end
  
  def user_id_from_params(params)
    return case params
    when Integer
      params
    when User
      params.id
    when /\A\d+\z/
      params.to_i
    when String
      User.find_by(username: params)&.id
    else
      nil
    end
  end
  
  def post_id_from_params(params)
    return case params
    when Integer
      params
    when User
      params.id
    when /\A\d+\z/
      params.to_i
    else
      nil
    end
  end
end
