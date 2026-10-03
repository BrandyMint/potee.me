# A user without an email is anonymous: everyone gets a board on the first
# visit and can register later to keep it (see RegistrationsController).
class User < ApplicationRecord
  has_secure_password validations: false

  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :project_connections, dependent: :destroy
  has_many :projects, through: :project_connections
  has_one :dashboard, dependent: :destroy
  has_many :plan_requests, dependent: :delete_all

  normalizes :email, with: ->(email) { email.strip.downcase.presence }

  validates :email, presence: true, on: :registration
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true, allow_nil: true
  validates :password, presence: true, on: :registration
  validates :password, length: { in: 8..72 }, allow_nil: true
  validates :locale, inclusion: { in: -> { I18n.available_locales.map(&:to_s) } }, allow_nil: true
  validates :region, inclusion: { in: WorkCalendar::REGIONS }, allow_nil: true

  scope :anonymous, -> { where(email: nil) }
  scope :registered, -> { where.not(email: nil) }
  scope :abandoned, ->(since = 30.days.ago) { anonymous.where(last_seen_at: ...since) }

  after_create :create_dashboard!

  API_TOKEN_PREFIX = "potee_"

  def self.digest_api_token(token)
    OpenSSL::Digest::SHA256.hexdigest(token.to_s)
  end

  def self.find_by_api_token(token)
    return if token.blank? || !token.start_with?(API_TOKEN_PREFIX)

    registered.find_by(api_token_digest: digest_api_token(token))
  end

  def anonymous?
    email.blank?
  end

  # Issues a new agent token (the previous one stops working) and returns it;
  # it is shown once and only its digest is kept.
  def regenerate_api_token!
    token = "#{API_TOKEN_PREFIX}#{SecureRandom.base58(40)}"
    update!(api_token_digest: self.class.digest_api_token(token))
    token
  end

  def api_token?
    api_token_digest.present?
  end

  # First-touch UTM tag ("source", "medium", "campaign", …), see attribution/v1.
  def utm(key)
    attribution&.dig("utm", key.to_s)
  end

  def attribution_summary
    %w[source medium campaign content].filter_map { utm(_1) }.join(" / ").presence
  end

  def to_s
    email.presence || "Incognito"
  end
  alias_method :label, :to_s

  # Projects in the order the user arranged them, with everything the board needs.
  def board_connections
    project_connections.includes(project: :events).order(:position, :created_at)
  end

  def next_color_index
    used = project_connections.pluck(:color_index)
    (0...ProjectConnection::COLORS_COUNT).find { |i| used.exclude?(i) } ||
      used.size % ProjectConnection::COLORS_COUNT
  end
end
