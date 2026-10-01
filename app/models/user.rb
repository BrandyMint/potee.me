# A user without an email is anonymous: everyone gets a board on the first
# visit and can register later to keep it (see RegistrationsController).
class User < ApplicationRecord
  has_secure_password validations: false

  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :project_connections, dependent: :destroy
  has_many :projects, through: :project_connections
  has_one :dashboard, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase.presence }

  validates :email, presence: true, on: :registration
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true, allow_nil: true
  validates :password, presence: true, on: :registration
  validates :password, length: { in: 8..72 }, allow_nil: true

  scope :anonymous, -> { where(email: nil) }
  scope :registered, -> { where.not(email: nil) }
  scope :abandoned, ->(since = 30.days.ago) { anonymous.where(last_seen_at: ...since) }

  after_create :create_dashboard!

  def anonymous?
    email.blank?
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
