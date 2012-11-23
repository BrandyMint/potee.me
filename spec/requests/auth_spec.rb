# encoding: utf-8

require 'requests/requests_helper'
USER_NAME = 'Barak Obama'

RSpec.configure do |config|
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:twitter, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => USER_NAME,
    }
  })
  OmniAuth.config.add_mock(:facebook, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => USER_NAME,
    }
  })
  OmniAuth.config.add_mock(:google_oauth2, {
    :uid => '12345',
    :nickname => 'bobama',
    :info => {
      :name => USER_NAME,
    }
  })
end


feature "auth", :js => true do
  background do
    visit("/projects")
  end

  scenario 'twitter_auth' do
    find('li.auth-twitter a').click
    find("li.signed_user").should have_content(USER_NAME)
  end

  scenario 'facebook_auth' do
    find('li.auth-facebook a').click
    find("li.signed_user").should have_content(USER_NAME)
  end

  scenario 'google_auth' do
    find('li.auth-google a').click
    find("li.signed_user").should have_content(USER_NAME)
  end
  
end
