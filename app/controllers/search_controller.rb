class SearchController < ApplicationController
  def index
    if params[:q]&.blank?
      redirect_to new_search_path and return
    end
    case params[:f]&.to_sym
    when :users
      @users = User.bio_search(params[:q]).page(params[:page]).per(10).without_count
      render :users_index
    else
      @posts = Post.text_search(params[:q]).reorder('created_at DESC').page(params[:page]).per(10).without_count
      render :index
    end
  end
  
  def new
  end
end
