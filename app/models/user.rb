class User < ApplicationRecord
  has_many :authentications, dependent: :destroy
  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :project_connections, dependent: :destroy
  has_many :projects, through: :project_connections
  has_one :dashboard, dependent: :destroy

  scope :anonymous, -> { where.missing(:authentications) }

  after_create :create_dashboard!

  def anonymous?
    authentications.empty?
  end

  def to_s
    name.presence || email.presence || "Incognito"
  end

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
