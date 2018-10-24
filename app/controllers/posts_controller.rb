class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:timeline, :new, :create]
  
  def timeline
    @posts = current_user.private_timeline_posts.page(params[:page]).per(25)
    
    @new_post = Post.new(params[:post])
    
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def create
    @new_post = current_user.posts.build(params.require(:post).permit(:content, attachments: []))
    @new_post.username = current_user.username
    @new_post.display_name = current_user.display_name
    @new_post.original_post_id = params[:original_post_id]
    @new_post.original_user_id = params[:original_user_id]
    @new_post.repost = (params[:post][:repost] == "true")
 
    if @new_post.save
      redirect_to root_url
    else
      render :new
    end
  end
  
  def new
    @new_post = Post.new(params[:post])
  end
  
  def show
    @post = Post.find(params[:id])
    if @post.user.private_account? && (current_user.nil? || !current_user.friend_with?(@post.user))
      render :private_post and return
    end
  end
end
