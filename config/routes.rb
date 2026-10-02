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
  resource :account, only: %i[show update]
  post "account/token" => "accounts#create_token", as: :account_token

  # MCP server for AI agents (see McpController)
  # A browser opening /mcp gets the connection guide; MCP clients get the API.
  post "mcp" => "mcp#handle"
  get "mcp" => "mcp_guides#show", constraints: ->(request) { request.headers["Accept"].to_s.include?("text/html") }
  get "mcp" => "mcp#stream"

  namespace :api, defaults: { format: :json } do
    resource :board, only: :show
    resource :dashboard, only: :update
    resources :projects, only: %i[create update destroy] do
      patch :reorder, on: :collection
      resources :events, only: :create
    end
    resources :events, only: %i[update destroy]
    resources :plan_requests, only: %i[create show] do
      member do
        post :apply
        post :discard
      end
    end
  end

  namespace :admin do
    resources :users
    resources :projects
    resources :events
    resources :project_connections
    resources :plan_requests, only: %i[index show]
    root to: "users#index"
  end
end
