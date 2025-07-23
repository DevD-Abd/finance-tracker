Rails.application.routes.draw do
  devise_for :users
  
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Main application routes
  resources :stocks, only: [:index, :show, :create, :update]
  root to: 'stocks#index'
end
