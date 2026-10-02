# Potee works without registration: the first visit to the board creates an
# anonymous user with a demo board and remembers it in the session. Signing up
# turns that user into an account; logging in merges it into one.
module CurrentUser
  extend ActiveSupport::Concern

  LAST_SEEN_PRECISION = 1.hour

  included do
    helper_method :current_user, :session_user
  end

  private

  def current_user
    @current_user ||= session_user || create_anonymous_user
  end

  # The user remembered in the session, without creating one.
  def session_user
    return @session_user if defined?(@session_user)

    @session_user = session[:user_id] && User.find_by(id: session[:user_id])
    @session_user&.then { |user| touch_last_seen(user) }
    @session_user
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    @current_user = @session_user = user
  end

  def sign_out
    reset_session
    @current_user = nil
    remove_instance_variable(:@session_user) if defined?(@session_user)
  end

  def create_anonymous_user
    user = User.transaction do
      User.create!(last_seen_at: Time.current).tap { |new_user| DemoBoard.fill(new_user) }
    end
    session[:user_id] = user.id
    @session_user = user
  end

  def touch_last_seen(user)
    return if user.last_seen_at && user.last_seen_at > LAST_SEEN_PRECISION.ago

    user.update_column(:last_seen_at, Time.current)
  end

  def board_payload
    {
      projects: current_user.board_connections.map { |connection| card_json(connection) },
      dashboard: current_user.dashboard.as_board_json,
      user: { email: current_user.email, anonymous: current_user.anonymous? },
      features: { plan_from_text: PlanRequest.enabled? },
      locale: I18n.locale
    }
  end

  def card_json(connection)
    connection.as_card_json(share_url: share_url(connection.share_key))
  end
end
