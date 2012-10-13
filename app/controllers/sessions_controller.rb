class SessionsController < ApplicationController
  def create
    user = Authentication.authenticate_or_create(auth)
    session[:user_id] = user.id
    redirect_to root_url, notice: 'Logged in!'
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
