require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'headless'
require 'capybara/poltergeist'


USER_NAME = 'Barak Obama'

RSpec.configure do |config|

  # :webkit пока нормально не работает (https://github.com/thoughtbot/capybara-webkit/issues/366)
  Capybara.javascript_driver = :poltergeist
  Capybara.default_host = '127.0.0.1'
  Capybara.server_port = 30009
  Capybara.app_host = "http://test.host:30009"
  #Capybara.server_boot_timeout = 60
  Capybara.default_wait_time = 10

  #Capybara.register_driver :remote_firefox do |app|
    #Capybara::Selenium::Driver.new(app,
                                   #:browser => :remote,
                                   #:url => "http://office.icfdev.ru:4444/wd/hub",
                                   #:desired_capabilities => :firefox)
  #end

  #Capybara.register_driver :remote_ie do |app|
    #Capybara::Selenium::Driver.new(app,
                                   #:browser => :remote,
                                   #:url => "http://office.icfdev.ru:4444/wd/hub",
                                   #:desired_capabilities => :ie)
  #end

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

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  def multibrowser_testing &block
    [:webkit, :remote_firefox].each do |driver|
      if driver == :webkit
        Capybara.app_host = "http://test.host:30009"
        Capybara.default_wait_time = 10
      else
        Capybara.app_host = "http://192.168.1.1:30009"
        Capybara.default_wait_time = 40
      end
      @driver = driver
      block.call
    end
  end

end


