require 'securerandom'

class ProjectConnection < ActiveRecord::Base
  attr_protected :secret

  belongs_to :project
  belongs_to :user

  has_many :events, through: :project

  before_validation do
    self.color_index ||= 1
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

  delegate :title, :started_at, :finish_at, :events, to: :project

  def as_json *args
    serializable_hash methods: [:title, :started_at, :finish_at, :events],
      include: :events
  end

end
