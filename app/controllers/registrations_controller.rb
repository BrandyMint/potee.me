# Sign-up keeps the visitor's board: the anonymous session user becomes the account.
class RegistrationsController < ApplicationController
  include CurrentUser

  layout "auth"

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to signup_path, alert: "Too many attempts. Try again later." }

  def new
    redirect_to board_path unless session_user.nil? || session_user.anonymous?
  end

  def create
    @email = params[:email].to_s
    if User.registered.exists?(email: @email.strip.downcase)
      flash.now[:alert] = "This email is already registered. Log in instead."
      return render :new, status: :unprocessable_content
    end

    user = session_user&.anonymous? ? session_user : User.new
    user.assign_attributes(email: @email, password: params[:password])
    new_board = user.new_record?
    if user.save(context: :registration)
      DemoBoard.fill(user) if new_board
      sign_in(user)
      redirect_to board_path, notice: "Welcome! Your board is saved to #{user.email}."
    else
      flash.now[:alert] = user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end
end
