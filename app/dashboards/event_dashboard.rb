require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    project: Field::BelongsTo,
    at: Field::DateTime.with_options(format: "%d.%m.%Y %H:%M", timezone: "Europe/Moscow"),
    created_at: Field::DateTime.with_options(format: "%d.%m.%Y %H:%M", timezone: "Europe/Moscow")
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id title project at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id title project at created_at].freeze
  FORM_ATTRIBUTES = %i[title at].freeze

  def display_resource(event)
    event.title
  end
end
