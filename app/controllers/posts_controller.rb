class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:timeline, :new, :create]
  
  def timeline
    @posts = current_user.private_timeline_posts
    
    @new_post = Post.new(params[:post])
  end
  
  def create
    @new_post = current_user.posts.build(params.require(:post).permit(:content))
    @new_post.username = current_user.username
    @new_post.display_name = current_user.display_name
 
    if @new_post.save
      redirect_to root_url
    else
      render :new
    end
  end
  
  def new
    @new_post = Post.new(params[:post])
  end
end
