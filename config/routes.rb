Rails.application.routes.draw do
  devise_for :users
  
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

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
