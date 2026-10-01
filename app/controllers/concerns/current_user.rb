# Potee works without registration: the first visit to the board creates an
# anonymous user with a demo board and remembers it in the session.
module CurrentUser
  extend ActiveSupport::Concern

  LAST_SEEN_PRECISION = 1.hour

  included do
    helper_method :current_user
  end

  private

  def current_user
    @current_user ||= session_user || create_anonymous_user
  end

  def session_user
    user = User.find_by(id: session[:user_id]) if session[:user_id]
    return unless user

    user.update_column(:last_seen_at, Time.current) if user.last_seen_at.nil? || user.last_seen_at < LAST_SEEN_PRECISION.ago
    user
  end

  def create_anonymous_user
    user = User.transaction do
      User.create!(last_seen_at: Time.current).tap { |new_user| DemoBoard.fill(new_user) }
    end
    session[:user_id] = user.id
    user
  end

  def board_payload
    {
      projects: current_user.board_connections.map { |connection| card_json(connection) },
      dashboard: current_user.dashboard.as_board_json,
      user: { name: current_user.to_s, anonymous: current_user.anonymous? }
    }
  end

  def card_json(connection)
    connection.as_card_json(share_url: share_url(connection.share_key))
  end
end
