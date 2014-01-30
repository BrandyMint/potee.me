class WelcomeController < ApplicationController

  def index
    redirect_to projects_url unless current_user.incognito?
  end

end
