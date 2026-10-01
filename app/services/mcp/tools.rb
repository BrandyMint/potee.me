module Mcp
  # Board operations exposed to AI agents as MCP tools. Projects are addressed
  # by the user's board row id (`project_id`), like in the web API. Dates are
  # calendar days (YYYY-MM-DD); event times are wall-clock "HH:MM" in
  # `timezone` (Europe/Moscow by default).
  class Tools
    class Error < StandardError; end

    DEFAULT_TIMEZONE = "Europe/Moscow".freeze
    DEFAULT_EVENT_TIME = "12:00".freeze

    DATE = { type: "string", pattern: '^\d{4}-\d{2}-\d{2}$', description: "Calendar date YYYY-MM-DD" }.freeze
    TIME = { type: "string", pattern: '^\d{2}:\d{2}$', description: "Wall-clock time HH:MM (default 12:00)" }.freeze
    TIMEZONE = { type: "string", description: "IANA timezone for dates and times, default Europe/Moscow" }.freeze
    COLOR = { type: "integer", minimum: 0, maximum: ProjectConnection::COLORS_COUNT - 1, description: "Colour 0–9" }.freeze
    EVENT_INPUT = {
      type: "object",
      properties: { title: { type: "string" }, date: DATE, time: TIME },
      required: %w[title date]
    }.freeze

    DEFINITIONS = [
      {
        name: "list_projects",
        description: "List the projects on the user's Potee board in board order, with their milestones (events) and share links.",
        inputSchema: { type: "object", properties: { timezone: TIMEZONE } }
      },
      {
        name: "create_project",
        description: "Create a project (a bar on the timeline from start_date to end_date, inclusive) at the end of the board, optionally with milestones. Every milestone date must be within the project dates.",
        inputSchema: {
          type: "object",
          properties: {
            title: { type: "string" }, start_date: DATE, end_date: DATE, color: COLOR,
            events: { type: "array", items: EVENT_INPUT, description: "Milestones to add" },
            timezone: TIMEZONE
          },
          required: %w[title start_date end_date]
        }
      },
      {
        name: "update_project",
        description: "Rename a project, change its dates or colour. Dates cannot exclude existing milestones.",
        inputSchema: {
          type: "object",
          properties: { project_id: { type: "integer" }, title: { type: "string" }, start_date: DATE, end_date: DATE, color: COLOR, timezone: TIMEZONE },
          required: %w[project_id]
        }
      },
      {
        name: "delete_project",
        description: "Remove a project from the board. If the user owns it, the project is deleted for everyone it is shared with.",
        inputSchema: { type: "object", properties: { project_id: { type: "integer" } }, required: %w[project_id] }
      },
      {
        name: "add_event",
        description: "Add a milestone to a project. The date must be within the project dates.",
        inputSchema: {
          type: "object",
          properties: { project_id: { type: "integer" }, title: { type: "string" }, date: DATE, time: TIME, timezone: TIMEZONE },
          required: %w[project_id title date]
        }
      },
      {
        name: "update_event",
        description: "Rename a milestone or move it to another date/time within its project.",
        inputSchema: {
          type: "object",
          properties: { event_id: { type: "integer" }, title: { type: "string" }, date: DATE, time: TIME, timezone: TIMEZONE },
          required: %w[event_id]
        }
      },
      {
        name: "delete_event",
        description: "Delete a milestone.",
        inputSchema: { type: "object", properties: { event_id: { type: "integer" } }, required: %w[event_id] }
      }
    ].freeze

    def initialize(user, share_url:)
      @user = user
      @share_url = share_url
    end

    def definitions
      DEFINITIONS
    end

    def call(name, arguments)
      raise Error, "Unknown tool: #{name}" unless DEFINITIONS.any? { _1[:name] == name }

      @args = (arguments || {}).to_h.with_indifferent_access
      @zone = zone(@args[:timezone])
      public_send(name)
    end

    def list_projects
      { today: Time.current.in_time_zone(@zone).to_date.iso8601, timezone: @zone.tzinfo.name,
        projects: @user.board_connections.map { project_json(_1) } }
    end

    def create_project
      events = Array(@args[:events])
      connection = ProjectConnection.transaction do
        project = @user.owned_projects.create!(
          title: required(:title), started_on: date(required(:start_date)), finished_on: date(required(:end_date))
        )
        connection = project.project_connections.create!(
          user: @user,
          color_index: @args.fetch(:color, @user.next_color_index),
          position: @user.project_connections.maximum(:position).to_i + 1
        )
        events.each { |event| create_event(project, event.with_indifferent_access) }
        connection
      end
      project_json(connection.reload)
    end

    def update_project
      connection = find_connection
      project = connection.project
      ProjectConnection.transaction do
        project.edited!
        attributes = { title: @args[:title], started_on: @args[:start_date] && date(@args[:start_date]),
                       finished_on: @args[:end_date] && date(@args[:end_date]) }.compact
        if attributes.key?(:started_on) || attributes.key?(:finished_on)
          check_events_inside!(project, attributes.fetch(:started_on, project.started_on), attributes.fetch(:finished_on, project.finished_on))
        end
        project.update!(attributes) if attributes.any?
        connection.update!(color_index: @args[:color]) if @args.key?(:color)
      end
      project_json(connection.reload)
    end

    def delete_project
      connection = find_connection
      title = connection.title
      connection.destroy!
      { deleted: true, title: }
    end

    def add_event
      connection = find_connection
      connection.project.edited!
      event = create_event(connection.project, @args)
      event_json(event)
    end

    def update_event
      event = find_event
      project = event.project
      project.edited!
      at = if @args[:date] || @args[:time]
        local = event.at.in_time_zone(@zone)
        moment(@args[:date] ? date(@args[:date]) : local.to_date, @args[:time] || local.strftime("%H:%M"))
      end
      check_inside!(project, at) if at
      event.update!({ title: @args[:title], at: }.compact)
      event_json(event)
    end

    def delete_event
      event = find_event
      event.project.edited!
      event.destroy!
      { deleted: true, title: event.title }
    end

    private

    def project_json(connection)
      {
        project_id: connection.id,
        title: connection.title,
        start_date: connection.started_on.iso8601,
        end_date: connection.finished_on.iso8601,
        color: connection.color_index,
        owner: connection.owner?,
        share_url: @share_url.call(connection.share_key),
        events: connection.events.map { event_json(_1) }
      }
    end

    def event_json(event)
      local = event.at.in_time_zone(@zone)
      { event_id: event.id, title: event.title, date: local.to_date.iso8601, time: local.strftime("%H:%M") }
    end

    def create_event(project, attributes)
      at = moment(date(attributes[:date] || raise(Error, "Event date is required")), attributes[:time] || DEFAULT_EVENT_TIME)
      check_inside!(project, at)
      project.events.create!(title: attributes[:title].presence || raise(Error, "Event title is required"), at:)
    end

    def check_inside!(project, at)
      day = at.in_time_zone(@zone).to_date
      return if day.between?(project.started_on, project.finished_on)

      raise Error, "#{day} is outside the project dates #{project.started_on}..#{project.finished_on}; " \
                   "extend the project with update_project first"
    end

    def check_events_inside!(project, started_on, finished_on)
      raise Error, "end_date must not be before start_date" if finished_on < started_on

      outside = project.events.reject { _1.at.in_time_zone(@zone).to_date.between?(started_on, finished_on) }
      return if outside.empty?

      raise Error, "Milestones would fall outside the new dates: #{outside.map(&:title).join(', ')}; move or delete them first"
    end

    def find_connection
      @user.project_connections.find_by(id: required(:project_id)) ||
        raise(Error, "Project #{@args[:project_id]} is not on this board; call list_projects")
    end

    def find_event
      Event.where(project_id: @user.project_connections.select(:project_id)).find_by(id: required(:event_id)) ||
        raise(Error, "Event #{@args[:event_id]} is not on this board; call list_projects")
    end

    def required(key)
      @args[key].presence || raise(Error, "#{key} is required")
    end

    def date(value)
      Date.iso8601(value.to_s)
    rescue Date::Error
      raise Error, "Invalid date #{value.inspect}, expected YYYY-MM-DD"
    end

    def moment(day, time)
      hours, minutes = time.to_s.split(":").map { Integer(_1, 10) }
      raise Error, "Invalid time #{time.inspect}, expected HH:MM" unless hours&.between?(0, 23) && minutes&.between?(0, 59)

      @zone.local(day.year, day.month, day.day, hours, minutes)
    rescue ArgumentError, TypeError
      raise Error, "Invalid time #{time.inspect}, expected HH:MM"
    end

    def zone(name)
      ActiveSupport::TimeZone[name.presence || DEFAULT_TIMEZONE] || raise(Error, "Unknown timezone #{name}")
    end
  end
end
