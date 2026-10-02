class WelcomeController < ApplicationController
  include CurrentUser

  def show
    redirect_to board_path unless session_user.nil? || session_user.anonymous?
  end
end
