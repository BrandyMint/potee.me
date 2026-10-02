# Creates projects with milestones at the end of a user's board. Shared by
# the MCP tools and "plan from text"; callers validate the input first.
class BoardWriter
  def initialize(user)
    @user = user
  end

  # events: [{ title:, at: Time }]
  def add_project(title:, started_on:, finished_on:, events: [], color_index: nil)
    ProjectConnection.transaction do
      project = @user.owned_projects.create!(title:, started_on:, finished_on:)
      connection = project.project_connections.create!(
        user: @user,
        color_index: color_index || @user.next_color_index,
        position: @user.project_connections.maximum(:position).to_i + 1
      )
      events.each { |event| project.events.create!(title: event[:title], at: event[:at]) }
      connection
    end
  end
end
