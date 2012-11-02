require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'headless'

USER_NAME = 'Barak Obama'

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

  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:twitter, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => USER_NAME
    }
  })
  OmniAuth.config.add_mock(:facebook, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => USER_NAME
    }
  })
  OmniAuth.config.add_mock(:google_oauth2, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => USER_NAME
    }
  })

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


