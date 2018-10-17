class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable, :omniauthable, omniauth_providers: %i[solfanto_oauth2]
  
  validates :provider, presence: true
  
  has_many :posts, dependent: :nullify
  has_many :likes
  has_many :follows
  has_many :followings, class_name: 'User', through: :follows
  
  before_create :set_tmp_username
  
  def timeline_posts
    @timeline_posts ||= Post.where(user: [self] + self.followings).order('created_at DESC')
  end
         
  def self.from_omniauth(auth)
    raise if auth.uid.nil?
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
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
