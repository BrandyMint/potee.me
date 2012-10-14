class WelcomeController < ApplicationController

  def index
    redirect_to projects_path if current_user
  end

end
