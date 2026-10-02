# Turns a model's answer into a valid draft (FT-001 INV-01..INV-05): bad
# dates and milestones are dropped, inverted dates swapped, projects stretched
# to cover their milestones, sizes capped.
class PlanNormalizer
  MAX_PROJECTS = 6
  MAX_EVENTS = 12
  HORIZON = 2.years

  def initialize(today:)
    @today = today
  end

  # Returns { "projects" => [...] } or nil when nothing usable is left.
  def call(data)
    projects = Array(data.is_a?(Hash) ? data["projects"] : nil).first(MAX_PROJECTS).filter_map { project(_1) }
    return if projects.empty?

    { "projects" => projects.each_with_index.map { |project, index| project.merge("key" => "p#{index + 1}") } }
  end

  private

  def project(raw)
    return unless raw.is_a?(Hash)

    start = date(raw["start_date"])
    finish = date(raw["end_date"])
    events = Array(raw["events"]).first(MAX_EVENTS).filter_map { event(_1) }.sort_by { [ _1["date"], _1["time"].to_s ] }
    start ||= events.first&.then { Date.iso8601(_1["date"]) }
    finish ||= events.last&.then { Date.iso8601(_1["date"]) }
    return unless start && finish

    start, finish = finish, start if finish < start
    adjusted = false
    events.each do |event|
      day = Date.iso8601(event["date"])
      if day < start then start = day; adjusted = true end
      if day > finish then finish = day; adjusted = true end
    end

    {
      "title" => title(raw["title"], "Проект"),
      "start_date" => start.iso8601,
      "end_date" => finish.iso8601,
      "adjusted" => adjusted,
      "events" => events
    }
  end

  def event(raw)
    return unless raw.is_a?(Hash)

    day = date(raw["date"])
    return unless day

    { "title" => title(raw["title"], "Событие"), "date" => day.iso8601, "time" => time(raw["time"]) }
  end

  def date(value)
    day = Date.iso8601(value.to_s)
    day if (@today - HORIZON..@today + HORIZON).cover?(day)
  rescue Date::Error
    nil
  end

  def time(value)
    value.to_s if value.to_s.match?(/\A([01]\d|2[0-3]):[0-5]\d\z/)
  end

  def title(value, fallback)
    value.to_s.strip.presence&.first(255) || fallback
  end
end
