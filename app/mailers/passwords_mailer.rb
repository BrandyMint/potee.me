class PasswordsMailer < ApplicationMailer
  # Sent in the language the reset was requested in (`with(locale:)`).
  def reset(user)
    @user = user
    I18n.with_locale(params&.dig(:locale) || I18n.default_locale) do
      mail subject: t(".subject"), to: user.email
    end
  end
end
