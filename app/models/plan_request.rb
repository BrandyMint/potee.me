# One "plan from text" request (FT-001): the user's text, the model's answer
# normalized into a draft, and what the user did with it.
class PlanRequest < ApplicationRecord
  MAX_PROMPT_LENGTH = 2000
  DAILY_LIMIT = 20
  STALE_AFTER = 3.minutes
  RETENTION = 30.days

  belongs_to :user

  enum :status, { pending: "pending", ready: "ready", failed: "failed", applied: "applied", discarded: "discarded" }, validate: true

  validates :prompt, presence: true, length: { maximum: MAX_PROMPT_LENGTH }
  validate :timezone_known

  scope :today, -> { where(created_at: Time.current.beginning_of_day..) }
  scope :expired, -> { where(created_at: ...RETENTION.ago) }

  def self.enabled?
    ENV["PLAN_FROM_TEXT_ENABLED"].present?
  end

  def zone
    ActiveSupport::TimeZone[timezone] || ActiveSupport::TimeZone["Europe/Moscow"]
  end

  # A generation interrupted by a restart never finishes; fail it on read.
  def fail_if_stale!
    return unless pending? && created_at < STALE_AFTER.ago

    update!(status: :failed, error: "interrupted", completed_at: Time.current)
  end

  def as_status_json
    { id:, status:, draft: (ready? || applied? ? draft : nil), error: (failed? ? error : nil) }.compact
  end

  private

  def timezone_known
    errors.add(:timezone, "is unknown") unless ActiveSupport::TimeZone[timezone.to_s]
  end
end
