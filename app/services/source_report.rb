# Weekly funnel of new boards by first-touch UTM tag (users.attribution, see
# attribution/v1 in corp-sales), for the admin report. Activation, return, sign-up and joining follow MET-01, MET-02,
# MET-03 and MET-05 of PRD-001; "shared" counts boards whose project someone
# else added, "planned" and "agent" the plan from text and an MCP token.
class SourceReport
  TIME_ZONE = "Europe/Moscow".freeze
  # Report dimension → SQL for that first-touch UTM tag.
  TAGS = %w[source medium campaign].index_with { "users.attribution->'utm'->>'#{_1}'" }.freeze
  WEEK = "date_trunc('week', users.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{TIME_ZONE}')::date".freeze

  # Each metric counts users matching the SQL condition.
  METRICS = {
    came: "true",
    activated: "EXISTS (SELECT 1 FROM projects WHERE projects.owner_id = users.id AND NOT projects.demo)",
    returned: "users.last_seen_at >= users.created_at + interval '7 days'",
    registered: "users.email IS NOT NULL",
    joined: "EXISTS (SELECT 1 FROM project_connections JOIN projects ON projects.id = project_connections.project_id " \
            "WHERE project_connections.user_id = users.id AND projects.owner_id <> users.id)",
    shared: "EXISTS (SELECT 1 FROM projects JOIN project_connections ON project_connections.project_id = projects.id " \
            "WHERE projects.owner_id = users.id AND project_connections.user_id <> users.id)",
    planned: "EXISTS (SELECT 1 FROM plan_requests WHERE plan_requests.user_id = users.id)",
    agent: "users.api_token_digest IS NOT NULL"
  }.freeze
  COUNTS = METRICS.values.map { "count(*) FILTER (WHERE #{_1})" }.freeze

  Row = Struct.new(:week, :tag, *METRICS.keys, keyword_init: true)

  def initialize(weeks: 8, by: "source")
    @since = weeks.weeks.ago.in_time_zone(TIME_ZONE).beginning_of_week
    @by = TAGS.key?(by.to_s) ? by.to_s : TAGS.keys.first
  end

  attr_reader :since, :by

  # One row per week and tag value, newest week first.
  def by_week
    rows(WEEK).sort_by { [ -_1.week.jd, _1.tag.to_s ] }
  end

  # One row per tag value over the whole period, the biggest first.
  def totals
    rows.sort_by { [ -_1.came, _1.tag.to_s ] }
  end

  private

  def rows(week = nil)
    keys = [ week, TAGS.fetch(@by) ].compact.map { Arel.sql(_1) }
    counts = COUNTS.map { Arel.sql(_1) }
    User.where(created_at: @since..).group(*keys).pluck(*keys, *counts).map do |values|
      week_start = values.shift if week
      Row.new(week: week_start, tag: values.shift, **METRICS.keys.zip(values).to_h)
    end
  end
end
