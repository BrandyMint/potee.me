require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'headless'

RSpec.configure do |config|
  Capybara.javascript_driver = :selenium # :webkit пока нормально не работает (https://github.com/thoughtbot/capybara-webkit/issues/366)
  Capybara.default_driver = :selenium
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
      :browser => :remote,
      :url => "http://office.icfdev.ru:4444/wd/hub",
      :desired_capabilities => :internet_explorer)
  end
  Capybara.default_host = '127.0.0.1'
  Capybara.server_port = 30009
  Capybara.app_host = "http://192.168.1.1:30009"
  Capybara.server_boot_timeout = 60
  Capybara.default_wait_time = 20

  # jenkins и обычный пользователь пускают X-ы на разных портах
  headless = Headless.new :destroy_at_exit => false, :display => `whoami`=~/jenkins/ ? 98 : 99
  headless.start

  config.use_transactional_fixtures = false

  config.before :each do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after :each do
    DatabaseCleaner.clean
  end

end


