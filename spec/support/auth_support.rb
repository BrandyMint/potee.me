# encoding: utf-8
def user_must_be_logged
  find("li.signed_user").should have_content(USER_NAME)
end

def user_must_be_unlogged
  find('div.navbar-text').should have_content('Sign up to save your projects')
end

