class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  private

  # The account's language; otherwise Russian by default, English when the
  # browser prefers it over Russian.
  def switch_locale(&)
    I18n.with_locale(account_locale || preferred_locale, &)
  end

  def account_locale
    respond_to?(:session_user, true) && session_user&.locale.presence
  end

  def preferred_locale
    languages = request.headers["Accept-Language"].to_s.split(",").map { _1.split(";").first.to_s.strip.downcase.first(2) }
    languages.map(&:to_sym).find { I18n.available_locales.include?(_1) } || I18n.default_locale
  end
end
