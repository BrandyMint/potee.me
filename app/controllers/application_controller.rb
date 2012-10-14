class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

protected

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def authorize_user
    unless current_user
      redirect_to root_url
    end
  end

end
