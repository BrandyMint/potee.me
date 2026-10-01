require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    email: Field::Email,
    label: Field::String.with_options(searchable: false),
    last_seen_at: Field::DateTime.with_options(format: "%d.%m.%Y %H:%M", timezone: "Europe/Moscow"),
    owned_projects: Field::HasMany.with_options(class_name: "Project"),
    project_connections: Field::HasMany,
    created_at: Field::DateTime.with_options(format: "%d.%m.%Y %H:%M", timezone: "Europe/Moscow")
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id label project_connections created_at last_seen_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id label created_at last_seen_at owned_projects project_connections].freeze
  FORM_ATTRIBUTES = %i[email].freeze

  COLLECTION_FILTERS = {
    registered: ->(resources) { resources.registered },
    anonymous: ->(resources) { resources.anonymous }
  }.freeze

  def display_resource(user)
    user.to_s
  end
end
