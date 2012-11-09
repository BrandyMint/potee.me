require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'headless'

RSpec.configure do |config|

  Capybara.javascript_driver = :selenium # :webkit пока нормально не работает (https://github.com/thoughtbot/capybara-webkit/issues/366)
  Capybara.default_host = '127.0.0.1'
  Capybara.server_port = 30009
  Capybara.app_host = "http://test.host:30009"
  Capybara.server_boot_timeout = 60
  Capybara.default_wait_time = 10

  # jenkins и обычный пользователь пускают X-ы на разных портах
  headless = Headless.new :destroy_at_exit => false, :display => `whoami`=~/jenkins/ ? 98 : 99
  headless.start

  config.use_transactional_fixtures = false

  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:twitter, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => 'Barak Obama',
    }
  })

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


