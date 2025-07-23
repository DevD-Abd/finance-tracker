Rails.application.routes.draw do
  devise_for :users
  
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # User profile routes
  resources :users, only: [:show], param: :id

  # Friendship routes
  resources :friendships, only: [:index, :create, :destroy]

  # Main application routes
  resources :stocks, only: [:index, :show, :create, :update] do
    collection do
      get :browse
    end
    member do
      post :track
      delete :untrack
    end
  end
  
  root to: 'stocks#index'
end
