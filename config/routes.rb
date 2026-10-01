Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "welcome#show"
  get "projects" => "boards#show", as: :board
  get "share/:share_key" => "shares#show", as: :share

  get "signup" => "registrations#new"
  post "signup" => "registrations#create"
  get "login" => "sessions#new"
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy"
  resources :passwords, param: :token, only: %i[new create edit update]
  resource :account, only: :show
  post "account/token" => "accounts#create_token", as: :account_token

  # MCP server for AI agents (see McpController)
  post "mcp" => "mcp#handle"
  get "mcp" => "mcp#stream"

  namespace :api, defaults: { format: :json } do
    resource :board, only: :show
    resource :dashboard, only: :update
    resources :projects, only: %i[create update destroy] do
      patch :reorder, on: :collection
      resources :events, only: :create
    end
    resources :events, only: %i[update destroy]
  end

  namespace :admin do
    resources :users
    resources :projects
    resources :events
    resources :project_connections
    root to: "users#index"
  end
end
