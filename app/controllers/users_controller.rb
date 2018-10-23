class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:follow, :unfollow, :edit]
  
  def show
    @user = User.find_by(username: params[:username])
    @posts = @user.public_timeline_posts.page(params[:page]).per(10).without_count
  end
  
  def follow
    current_user.follow(params[:username])
    redirect_back(fallback_location: root_path)
  end
  
  def unfollow
    current_user.unfollow(params[:username])
    redirect_back(fallback_location: root_path)
  end
  
  def followers
    @user = User.find_by(username: params[:username])
    @users = @user.followers
  end
  
  def following
    @user = User.find_by(username: params[:username])
    @users = @user.followings
  end
  
  def like
    current_user.like(params[:post_id])
    respond_to do |format|
      format.js
      format.html {redirect_back(fallback_location: root_path)}
    end
  end
  
  def unlike
    current_user.unlike(params[:post_id])
    respond_to do |format|
      format.js
      format.html {redirect_back(fallback_location: root_path)}
    end
  end
end
