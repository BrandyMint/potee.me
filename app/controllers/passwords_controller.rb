# Password reset by an emailed link (Rails' has_secure_password reset tokens,
# valid for 15 minutes and invalidated by a password change).
class PasswordsController < ApplicationController
  include CurrentUser

  layout "auth"

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: I18n.t("flash.too_many_attempts") }

  before_action :find_user_by_token, only: %i[edit update]

  def new; end

  def create
    if (user = User.registered.find_by(email: params[:email].to_s.strip.downcase))
      PasswordsMailer.with(locale: user.locale.presence || I18n.locale.to_s).reset(user).deliver_later
    end
    redirect_to login_path, notice: t("flash.reset_sent")
  end

  def edit; end

  def update
    if params[:password].present? && @user.update(password: params[:password])
      sign_in(@user)
      redirect_to board_path, notice: t("flash.password_changed")
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence.presence || t("flash.enter_password")
      render :edit, status: :unprocessable_content
    end
  end

  private

  def find_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: t("flash.reset_invalid")
  end
end
