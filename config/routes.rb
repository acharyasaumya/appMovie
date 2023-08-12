# config/routes.rb
Rails.application.routes.draw do
  root 'movies#index'
  resources :movies, only: [:index, :show] do
    collection do
      get 'search'
    end
    member do
      post 'add_to_favorites'
    end
  end
  resources :favorites, only: [:index]

  # Other routes
end