require 'securerandom'

class ProjectConnection < ActiveRecord::Base
  MAX_COLOR_INDEX = 8
  attr_protected :secret

  belongs_to :project
  belongs_to :user

  has_many :events, through: :project

  before_validation do
    self.color_index ||= user.projects.count % MAX_COLOR_INDEX
  end

  validates :project, presence: true
  validates :user, presence: true
  validates :color_index, presence: true

  before_create do
    self.share_key = SecureRandom.hex
  end

  after_destroy do
    project.destroy if user_id == project.try( :owner_id )
  end

  delegate :owner_id, :title, :started_at, :finish_at, :events, to: :project

  def share_link
    Rails.application.routes.url_helpers.project_connection_url share_key
  end

  def as_json *args
    serializable_hash ProjectPresentation
  end

end
