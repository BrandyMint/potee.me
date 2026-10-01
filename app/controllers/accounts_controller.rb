# Account page: the agent (MCP) token and how to connect agents to the board.
class AccountsController < ApplicationController
  include CurrentUser

  layout "auth"

  before_action :require_account

  def show; end

  def create_token
    @token = session_user.regenerate_api_token!
    render :show
  end

  private

  def require_account
    redirect_to login_path unless session_user && !session_user.anonymous?
  end
end
