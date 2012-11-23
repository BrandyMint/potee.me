# encoding: utf-8

require 'requests/requests_helper'
require 'support/auth_support'

feature "auth", :js => true do
  background do
    visit("/projects")
  end

  scenario 'twitter_auth' do
    user_must_be_unlogged
    find('li.auth-twitter a').click
    user_must_be_logged
  end

  scenario 'facebook_auth' do
    user_must_be_unlogged
    find('li.auth-facebook a').click
    user_must_be_logged
  end

  scenario 'google_auth' do
    user_must_be_unlogged
    find('li.auth-google a').click
    user_must_be_logged
  end
  
end
