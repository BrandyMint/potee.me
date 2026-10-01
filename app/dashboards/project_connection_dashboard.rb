require "administrate/base_dashboard"

class ProjectConnectionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::BelongsTo,
    project: Field::BelongsTo,
    position: Field::Number,
    color_index: Field::Number,
    share_key: Field::String,
    created_at: Field::DateTime.with_options(format: "%d.%m.%Y %H:%M", timezone: "Europe/Moscow")
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id user project position color_index].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id user project position color_index share_key created_at].freeze
  FORM_ATTRIBUTES = %i[position color_index].freeze

  def display_resource(connection)
    "#{connection.user} → #{connection.project.title}"
  end
end
