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
  
  before_create :set_tmp_username
  
  validates :username, format: { with: /\A[a-zA-Z0-9_]+\Z/ }
  
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
  
  def follow?(user)
    Follow.where(user: self, following: user).count > 0
  end
  memoize :follow?
  
  def follow(user_params)
    if user_params.is_a?(String)
      user = User.find_by(username: user_params)
    else
      user = user_params
    end
    return if self.follow?(user)
    follow = Follow.new(user: self, following: user)
    follow_back = Follow.where(user: user, following: self).first
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
    if user_params.is_a?(String)
      user = User.find_by(username: user_params)
    else
      user = user_params
    end
    follow = Follow.where(user: self, following: user).first
    return if follow.nil?
    follow_back = Follow.where(user: user, following: self).first
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
end
