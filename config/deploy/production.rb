#Конфиг деплоя на production
server 'icfdev.ru', :app, :web, :db, :primary => true
set :branch, "master" unless exists?(:branch)
set :rails_env, "production"

require 'airbrake/capistrano'

