# Sign-up keeps the visitor's board: the anonymous session user becomes the account.
class RegistrationsController < ApplicationController
  include CurrentUser

  layout "auth"

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to signup_path, alert: I18n.t("flash.too_many_attempts") }

  def new
    redirect_to board_path unless session_user.nil? || session_user.anonymous?
  end

  def create
    @email = params[:email].to_s
    if User.registered.exists?(email: @email.strip.downcase)
      flash.now[:alert] = t("flash.email_taken")
      return render :new, status: :unprocessable_content
    end

    user = session_user&.anonymous? ? session_user : User.new(traffic_source)
    user.assign_attributes(email: @email, password: params[:password], locale: I18n.locale.to_s,
                           region: WorkCalendar.detect(time_zone: params[:time_zone], accept_language: request.headers["Accept-Language"]))
    new_board = user.new_record?
    if user.save(context: :registration)
      DemoBoard.fill(user) if new_board
      sign_in(user)
      redirect_to board_path, notice: t("flash.welcome", email: user.email)
    else
      flash.now[:alert] = user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end
end
