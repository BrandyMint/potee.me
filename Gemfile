source 'https://rubygems.org'

gem 'rails', '~> 3.2.13'

gem 'airbrake'

gem 'inherited_resources'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'unicorn'

gem "haml", ">= 3.0.0"
gem "haml-rails"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-twitter"
gem "omniauth-google-oauth2"
gem "rails_config"

group :daemons do
  gem 'foreverb'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'rails-backbone'
gem 'vendorer'

gem 'bootstrap-sass'

gem 'activeadmin'
gem 'mini_magick'
gem 'carrierwave'

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano_colors'
  gem 'capistrano-recipes0', '>= 1.1.0', :git => 'git://github.com/BrandyMint/capistrano-recipes0.git'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-fsevent', :require => false
  gem 'rb-inotify', :require => false
  gem 'holepicker', :require => false
end

group :development, :test do
  gem 'rspec-rails'
  gem 'headless'

  gem 'jasmine'
  gem "jasminerice"
  gem 'guard-jasmine'
  gem 'jasmine-jquery-rails'
  gem 'sinon-rails'
end

#group :test do
  #gem 'capybara'
  #gem 'capybara-webkit'
  #gem 'rr'
  #gem 'database_cleaner'
  #gem 'factory_girl_rails'
  #gem 'launchy'
#end

group :production do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
