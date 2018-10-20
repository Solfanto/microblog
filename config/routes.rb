Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }
  get 'users', to: redirect('/users/edit')
  
  # Home
  root to: 'posts#timeline'
  
  # Search
  get 'search', to: 'search#index'
  get 'search/new', to: 'search#new', as: :new_search
  
  # User info
  get 'u/:username', to: 'users#show', as: :user
  get 'u/:username/followers', to: 'users#followers', as: :followers
  get 'u/:username/following', to: 'users#following', as: :following
  
  post 'u/:username/follow', to: 'users#follow', as: :follow
  delete 'u/:username/follow', to: 'users#unfollow'
  
  # Posts
  resources :posts, only: [:show, :new, :create, :destroy]
  
  # Static
  get 'about', to: 'static#about'
end
