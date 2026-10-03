# Potee works without registration: the first visit to the board creates an
# anonymous user with a demo board and remembers it in the session. Signing up
# turns that user into an account; logging in merges it into one.
module CurrentUser
  extend ActiveSupport::Concern

  LAST_SEEN_PRECISION = 1.hour
  SOURCE_PARAMS = %i[ref utm_source].freeze

  included do
    helper_method :current_user, :session_user
    before_action :remember_traffic_source, if: -> { request.get? && request.format.html? }
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
      User.create!(last_seen_at: Time.current, **traffic_source).tap { |new_user| DemoBoard.fill(new_user) }
    end
    session[:user_id] = user.id
    @session_user = user
  end

  # Where the visitor came from, decided by the first page of the session and
  # given to the user created later: `?ref=club` (or `utm_source`), "share" for
  # a share link, and the host of an outside referrer.
  def remember_traffic_source
    return if session.key?(:source) || session[:user_id]

    session[:source] = SOURCE_PARAMS.filter_map { normalize_source(params[_1]) }.first || ("share" if controller_name == "shares")
    session[:referrer] = outside_referrer
  end

  def traffic_source
    { source: session[:source], referrer: session[:referrer] }
  end

  def normalize_source(value)
    value.to_s.downcase.gsub(/[^a-z0-9_.-]/, "").first(50).presence
  end

  def outside_referrer
    host = URI.parse(request.referer.to_s).host
    host unless host.nil? || host == request.host
  rescue URI::InvalidURIError
    nil
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
      calendar: calendar_json,
      locale: I18n.locale
    }
  end

  # Anonymous boards guess the region from the browser language on every visit.
  def calendar_json
    region = current_user.anonymous? ? WorkCalendar.detect(accept_language: request.headers["Accept-Language"]) : current_user.region
    WorkCalendar.for(region).as_board_json.merge(dim: current_user.dim_days_off)
  end

  def card_json(connection)
    connection.as_card_json(share_url: share_url(connection.share_key))
  end
end
