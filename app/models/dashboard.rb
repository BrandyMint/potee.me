# Per-user view state of the board: zoom, the date in the middle of the screen
# and the vertical scroll position.
class Dashboard < ApplicationRecord
  MIN_PIXELS_PER_DAY = 4
  MAX_PIXELS_PER_DAY = 200

  belongs_to :user

  validates :pixels_per_day, numericality: { only_integer: true, in: MIN_PIXELS_PER_DAY..MAX_PIXELS_PER_DAY }
  validates :scroll_top, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def as_board_json
    { pixels_per_day:, current_date: current_date&.iso8601, scroll_top: }
  end
end
