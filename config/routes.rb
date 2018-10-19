Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  root to: 'posts#timeline'
  get 'search', to: 'search#index'
  get 'search/new', to: 'search#new', as: :new_search
  
  resources :posts, only: [:show, :new, :create, :destroy]
end
