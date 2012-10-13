Potee::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match 'logout', to: 'sessions#destroy', as: 'logout'

  root to: 'welcome#index'

  resources :projects
  resources :events
end
