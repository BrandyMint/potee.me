# Weekly funnel of new boards by traffic source (users.source), for the admin
# report: how many came, started planning, came back, signed up, shared a
# project, tried the plan from text and connected an agent.
class SourceReport
  TIME_ZONE = "Europe/Moscow".freeze
  WEEK = "date_trunc('week', users.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{TIME_ZONE}')::date".freeze

  # Each metric counts users matching the SQL condition.
  METRICS = {
    came: "true",
    activated: "EXISTS (SELECT 1 FROM projects WHERE projects.owner_id = users.id AND NOT projects.demo)",
    returned: "users.last_seen_at > users.created_at + interval '1 day'",
    registered: "users.email IS NOT NULL",
    shared: "EXISTS (SELECT 1 FROM projects JOIN project_connections ON project_connections.project_id = projects.id " \
            "WHERE projects.owner_id = users.id AND project_connections.user_id <> users.id)",
    planned: "EXISTS (SELECT 1 FROM plan_requests WHERE plan_requests.user_id = users.id)",
    agent: "users.api_token_digest IS NOT NULL"
  }.freeze
  COUNTS = METRICS.values.map { "count(*) FILTER (WHERE #{_1})" }.freeze

  Row = Struct.new(:week, :source, *METRICS.keys, keyword_init: true)

  def initialize(weeks: 8)
    @since = weeks.weeks.ago.in_time_zone(TIME_ZONE).beginning_of_week
  end

  # One row per week and source, newest week first.
  def by_week
    rows(WEEK).sort_by { [ -_1.week.jd, _1.source.to_s ] }
  end

  # One row per source over the whole period, the biggest first.
  def by_source
    rows.sort_by { [ -_1.came, _1.source.to_s ] }
  end

  attr_reader :since

  private

  def rows(week = nil)
    keys = [ week, "users.source" ].compact.map { Arel.sql(_1) }
    counts = COUNTS.map { Arel.sql(_1) }
    User.where(created_at: @since..).group(*keys).pluck(*keys, *counts).map do |values|
      week_start = values.shift if week
      Row.new(week: week_start, source: values.shift, **METRICS.keys.zip(values).to_h)
    end
  end
end
