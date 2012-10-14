class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

protected

  def current_user
    return @current_user if @current_user

    if session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
      return @current_user if @current_user
    end

    @current_user = User.create! :name => 'Incognito'
    # save it temporary
    session[:user_id] = @current_user.id

    @current_user
  end

  def authorize_user
    unless current_user
      redirect_to root_url
    end
  end

end
