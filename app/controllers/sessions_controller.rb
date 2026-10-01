class SessionsController < ApplicationController
  include CurrentUser

  layout "auth"

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, alert: "Too many attempts. Try again later." }

  def new
    redirect_to board_path unless session_user.nil? || session_user.anonymous?
  end

  def create
    @email = params[:email].to_s
    user = User.authenticate_by(email: @email.strip.downcase, password: params[:password].to_s)
    unless user
      flash.now[:alert] = "Wrong email or password."
      return render :new, status: :unprocessable_content
    end

    anonymous = session_user if session_user&.anonymous?
    sign_in(user)
    BoardMerge.call(from: anonymous, into: user)
    redirect_to board_path
  end

  def destroy
    sign_out
    redirect_to root_path, status: :see_other
  end
end
