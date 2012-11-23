# encoding: utf-8

require 'requests/requests_helper'

feature "auth", :js => true do
  background do
    visit("/projects")
  end

  scenario 'twitter_realauth' do
    find('li.auth-twitter a').click
    fill_in('username_or_email', :with => Settings.devauth.email )
    fill_in('password', :with => Settings.devauth.twitter.password)
    click_button('Sign In')
    find("li.signed_user").should have_content(Settings.devauth.twitter.login)
  end

  scenario 'facebook_realauth' do
    find('li.auth-facebook a').click
    fill_in('email', :with => Settings.devauth.email)
    fill_in('pass', :with => Settings.devauth.facebook.password)
    click_button('Log In')
    find("li.signed_user").should have_content(Settings.devauth.facebook.login)
  end

  scenario 'google_realauth' do
    #find('li.auth-google a').click
    #fill_in('Email', :with => Settings.devauth.google.email)
    #fill_in('Passwd', :with => Settings.devauth.google.password)
    #uncheck('PersistentCookie')
    #click_button('signIn')
    #find("li.signed_user").should have_content(Settings.devauth.google.login)
    pending "ждет реализации"
  end
  
end
