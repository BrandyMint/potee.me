Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "welcome#show"
  get "projects" => "boards#show", as: :board
  get "share/:share_key" => "shares#show", as: :share

  namespace :api, defaults: { format: :json } do
    resource :board, only: :show
    resource :dashboard, only: :update
    resources :projects, only: %i[create update destroy] do
      patch :reorder, on: :collection
      resources :events, only: :create
    end
    resources :events, only: %i[update destroy]
  end
end
