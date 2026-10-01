# The session holds the (possibly anonymous) user id; keep it across browser
# restarts so an anonymous board is not lost when the browser closes.
Rails.application.config.session_store :cookie_store, key: "_potee_session", expire_after: 1.year
