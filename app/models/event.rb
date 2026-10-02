# A milestone inside a project, placed at a moment on the timeline.
class Event < ApplicationRecord
  belongs_to :project, touch: true

  normalizes :title, with: ->(title) { title.to_s.strip.first(255) }

  attribute :title, default: "Some event"

  validates :title, :at, presence: true

  def as_card_json
    { id:, title:, at: at.iso8601, timed: }
  end
end
