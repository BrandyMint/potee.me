#Конфик мультистейджа. Должен быть в начале.
#Стейдж нельзя называть 'stage', поэтому зовем его 'staging'
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#Приложение
set :application, "potee.me"

#Репозиторий
set :scm, :git
set :repository,  "git@github.com:BrandyMint/Potee.git"
set :deploy_via, :remote_cache
set :scm_verbose, true
#Используем локальные ключи для приватных репозиториев на github
#В ~/.ssh/config на локальной машине должен быть прописан ForwardAgent yes
#https://help.github.com/articles/using-ssh-agent-forwarding
ssh_options[:forward_agent] = true

#Учетные данные на сервере
set :user,      'wwwpotee'
set :deploy_to,  defer { "/home/#{user}/#{application}" }
set :use_sudo,   false

#Все остальное
set :keep_releases, 5
set :shared_children, fetch(:shared_children) + %w(public/uploads)

set :bundle_flags, "--deployment --quiet --binstubs"

before 'deploy:restart', 'deploy:migrate'
after 'deploy:restart', "deploy:cleanup"
after 'deploy:finalize_update', 'potee:symlink_configs', 'potee:bowerinstall'

#RVM, Bundler
load 'deploy/assets'
require "bundler/capistrano"
require "holepicker/capistrano"
require "recipes0/database_yml"
require "recipes0/init_d/unicorn"
require "recipes0/nginx"

namespace :potee do
   task :symlink_configs, :except => { :no_release => true } do
      run "cp -r -s --force --remove-destination #{shared_path}/config #{release_path}"
   end
   task :bowerinstall, :except => { :no_release => true } do
       run "cd #{release_path} && bower install"
   end
end

