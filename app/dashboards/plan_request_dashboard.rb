require "administrate/base_dashboard"

# FT-001: read-only view of plan-from-text requests for quality review.
class PlanRequestDashboard < Administrate::BaseDashboard
  DATETIME = Field::DateTime.with_options(format: "%d.%m.%Y %H:%M", timezone: "Europe/Moscow")

  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::BelongsTo,
    prompt: Field::Text,
    status: Field::String,
    model: Field::String,
    error: Field::String,
    draft: Field::Text,
    raw_response: Field::Text,
    created_at: DATETIME,
    completed_at: DATETIME,
    applied_at: DATETIME
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id user status model error created_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id user status model error prompt draft raw_response created_at completed_at applied_at].freeze
  FORM_ATTRIBUTES = [].freeze

  COLLECTION_FILTERS = {
    failed: ->(resources) { resources.failed },
    applied: ->(resources) { resources.applied }
  }.freeze

  def display_resource(request)
    "Plan ##{request.id}"
  end
end
