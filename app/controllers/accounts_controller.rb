# Account page: the agent (MCP) token and how to connect agents to the board.
class AccountsController < ApplicationController
  include CurrentUser

  layout "auth"

  before_action :require_account

  def show; end

  def update
    if session_user.update(params.expect(user: %i[locale region dim_days_off]).transform_values(&:presence))
      redirect_to account_path, notice: t("account.settings.saved", locale: session_user.locale)
    else
      flash.now[:alert] = session_user.errors.full_messages.to_sentence
      render :show, status: :unprocessable_content
    end
  end

  def create_token
    @token = session_user.regenerate_api_token!
    render :show
  end

  private

  def require_account
    redirect_to login_path unless session_user && !session_user.anonymous?
  end
end
