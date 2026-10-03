module ApplicationHelper
  # Yandex Metrika counter "Potee — potee.pismenny.ru" (account danilpismenny).
  METRIKA_COUNTER = 113_370_026
  # Pages whose URL carries a secret (password reset token) get no counter.
  METRIKA_EXCLUDED_CONTROLLERS = %w[passwords].freeze

  def metrika_counter
    METRIKA_COUNTER if Rails.env.production? && !METRIKA_EXCLUDED_CONTROLLERS.include?(controller_name)
  end
end
