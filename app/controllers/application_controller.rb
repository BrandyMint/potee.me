class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_user_projects
  helper_method :canonical_url

  before_filter :redirect_domains

protected

  def current_user_projects
    current_user.project_connections.includes(:project, :events).order(:position, :created_at)
  end

  def current_user
    return @current_user if @current_user

    if session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
      return @current_user if @current_user
      # TODO Show flas: User destroyed
    end

    @current_user = User.create! :name => 'Incognito'
    @current_user.update_attribute :last_sign_in_at, Time.now
    # save it temporary
    session[:user_id] = @current_user.id

    @current_user
  end

  def authorize_user
    unless current_user
      redirect_to root_url
    end
  end

  def canonical_url
    request.original_url.gsub(request.host,Settings.application.host)
  end

  def redirect_domains
    unless Settings.application.hosts.include? request.host
      redirect_to canonical_url, :status => :moved_permanently
    end
  end

end
