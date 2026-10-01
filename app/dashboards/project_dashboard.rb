require "administrate/base_dashboard"

class ProjectDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    owner: Field::BelongsTo.with_options(class_name: "User"),
    started_on: Field::Date,
    finished_on: Field::Date,
    demo: Field::Boolean,
    events: Field::HasMany,
    project_connections: Field::HasMany,
    created_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id title owner started_on finished_on demo].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id title owner started_on finished_on demo created_at events project_connections].freeze
  FORM_ATTRIBUTES = %i[title started_on finished_on].freeze

  COLLECTION_FILTERS = {
    demo: ->(resources) { resources.where(demo: true) },
    real: ->(resources) { resources.where(demo: false) }
  }.freeze

  def display_resource(project)
    project.title
  end
end
