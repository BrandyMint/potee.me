require 'securerandom'

class ProjectConnection < ActiveRecord::Base
  attr_protected :secret

  belongs_to :project
  belongs_to :user

  validates :project_id, presence: true
  validates :user_id, presence: true

  before_create do
    self.share_key = SecureRandom.hex
  end

end
