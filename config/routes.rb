Potee::Application.routes.draw do
  match "/404", :to => "errors#not_found"

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: redirect('/')
  match 'logout', to: 'sessions#destroy', as: 'logout'

  root to: 'welcome#index'

  resources :projects
  resources :events
  resources :pages, :only => [] do
    collection do
      get :about
      get :team
      get :how_it_works
    end
  end
end
