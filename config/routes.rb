Rails.application.routes.draw do
  default_url_options(host: Rails.application.config.action_mailer.default_url_options[:host], port: Rails.application.config.action_mailer.default_url_options[:port])
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }
  get 'users', to: redirect('/users/edit')
  
  # Home
  root to: 'posts#timeline'
  get 'timeline/:page', to: 'posts#timeline'
  
  # Search
  get 'search', to: 'search#index'
  get 'search/new', to: 'search#new', as: :new_search
  
  # User info
  get 'u/:username', to: 'users#show', as: :user
  get 'u/:username/followers', to: 'users#followers', as: :followers
  get 'u/:username/following', to: 'users#following', as: :following
  
  # User actions
  post 'u/:username/follow', to: 'users#follow', as: :follow
  delete 'u/:username/follow', to: 'users#unfollow'
  post 'p/:post_id/like', to: 'users#like', as: :like
  delete 'p/:post_id/like', to: 'users#unlike'
  
  # Posts
  resources :posts, only: [:show, :new, :create, :destroy]
  get 'posts', to: redirect('/')
  
  # Static
  get 'about', to: 'static#about'
end
