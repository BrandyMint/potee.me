class SessionsController < ApplicationController

  def create
    projects = current_user.projects
    user = Authentication.authenticate_or_create(auth, current_user)
    # user already exist in our DB
    if user.id != current_user.id
      # move all unsaved projects to his/here account
      projects.update_all(user_id: user.id)
      # remove temp. user
      current_user.destroy
    end

    reset_session
    session[:user_id] = user.id
    redirect_to projects_url, notice: 'Logged in!'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: 'Logged out.'
  end

private

  def auth
    request.env['omniauth.auth']
  end

end
