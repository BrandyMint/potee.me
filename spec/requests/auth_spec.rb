# encoding: utf-8

require 'requests/requests_helper'


feature "auth", :js => true do
  background do
    visit("/projects")
  end
  
  scenario 'twitter_auth' do
    visit "/auth/twitter?force_login=true"
    find("li.signed_user").visible?
    save_and_open_page
    find("li.signed_user").should have_content('Barak Obama')
  end  


end
