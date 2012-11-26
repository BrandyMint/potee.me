Potee::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  h = { :host => Settings.application.host }
  h[:port] = 30009 if Rails.env.test?
  self.default_url_options h

  match "/404", :to => "errors#not_found"

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: redirect('/')

  match 'logout', to: 'sessions#destroy', as: 'logout'

  root to: 'welcome#index'

  resources :projects
  resources :events
  match 'dashboard/read', to: 'dashboards#read'
  match 'dashboard/update', to: 'dashboards#update'


  resources :pages, :only => [] do
    collection do
      get :about
      get :team
      get :how_it_works
    end
  end
end
