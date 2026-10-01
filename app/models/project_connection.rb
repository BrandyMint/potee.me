# A user's membership in a project: their own colour, position on the board and
# the key other people use to join the project.
class ProjectConnection < ApplicationRecord
  COLORS_COUNT = 10

  belongs_to :project
  belongs_to :user

  has_secure_token :share_key

  validates :color_index, numericality: { only_integer: true, in: 0...COLORS_COUNT }
  validates :project_id, uniqueness: { scope: :user_id }

  after_destroy :destroy_project_if_owner

  delegate :title, :started_on, :finished_on, :events, to: :project

  def owner?
    project.owner_id == user_id
  end

  # The JSON shape of one project row on the board.
  def as_card_json(share_url:)
    {
      id:,
      project_id:,
      title:,
      started_on: started_on.iso8601,
      finished_on: finished_on.iso8601,
      color_index:,
      position:,
      owner: owner?,
      share_url:,
      events: events.map(&:as_card_json)
    }
  end

  private

  def destroy_project_if_owner
    project.destroy if owner?
  end
end
