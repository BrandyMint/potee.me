class Project < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :events, -> { order(:at) }, dependent: :destroy, inverse_of: :project
  has_many :project_connections, dependent: :destroy

  normalizes :title, with: ->(title) { title.to_s.strip.first(255) }

  validates :title, :started_on, :finished_on, presence: true
  validate :finish_not_before_start

  private

  def finish_not_before_start
    return if started_on.blank? || finished_on.blank?

    errors.add(:finished_on, "must not be before the start") if finished_on < started_on
  end
end
