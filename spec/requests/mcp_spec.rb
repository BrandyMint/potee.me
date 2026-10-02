require "rails_helper"

RSpec.describe "MCP server", type: :request do
  let(:user) { User.create!(email: "dan@example.com", password: "secret-password") }
  let(:token) { user.regenerate_api_token! }

  def rpc(method, params = {}, id: 1, auth: token)
    headers = { "CONTENT_TYPE" => "application/json" }
    headers["Authorization"] = "Bearer #{auth}" if auth
    post(mcp_path, params: { jsonrpc: "2.0", id:, method:, params: }.to_json, headers:)
    response.parsed_body
  end

  def call_tool(name, arguments = {})
    rpc("tools/call", { name:, arguments: })["result"]
  end

  it "rejects requests without a valid token" do
    rpc("tools/list", auth: nil)
    expect(response).to have_http_status(:unauthorized)
    expect(response.headers["WWW-Authenticate"]).to include("Bearer")

    rpc("tools/list", auth: "potee_wrong")
    expect(response).to have_http_status(:unauthorized)
  end

  it "speaks the MCP handshake and lists the tools" do
    result = rpc("initialize", { protocolVersion: "2025-06-18", capabilities: {}, clientInfo: { name: "test", version: "1" } })["result"]
    expect(result).to include("protocolVersion" => "2025-06-18", "capabilities" => { "tools" => { "listChanged" => false } })
    expect(result["instructions"]).to include("list_projects")

    post mcp_path, params: { jsonrpc: "2.0", method: "notifications/initialized" }.to_json,
                   headers: { "CONTENT_TYPE" => "application/json", "Authorization" => "Bearer #{token}" }
    expect(response).to have_http_status(:accepted)

    names = rpc("tools/list")["result"]["tools"].map { _1["name"] }
    expect(names).to eq(%w[list_projects create_project update_project delete_project add_event update_event delete_event])
  end

  it "creates a project with milestones and changes it" do
    result = call_tool("create_project", {
      title: "Курс", start_date: "2026-10-01", end_date: "2026-10-28",
      events: [ { title: "Созвон 1", date: "2026-10-14", time: "19:00" }, { title: "Дедлайн", date: "2026-10-28" } ]
    })
    expect(result["isError"]).to be(false)
    project = result["structuredContent"]
    expect(project).to include("title" => "Курс", "start_date" => "2026-10-01", "end_date" => "2026-10-28", "owner" => true)
    expect(project["events"].map { _1.slice("title", "date", "time") }).to eq([
      { "title" => "Созвон 1", "date" => "2026-10-14", "time" => "19:00" },
      { "title" => "Дедлайн", "date" => "2026-10-28", "time" => nil }
    ])
    call_event, deadline = project["events"].map { Event.find(_1["event_id"]) }
    expect(call_event).to have_attributes(at: Time.utc(2026, 10, 14, 16, 0), timed: true)
    expect(deadline).to have_attributes(at: Time.utc(2026, 10, 28, 9, 0), timed: false)

    id = project["project_id"]
    updated = call_tool("update_project", { project_id: id, title: "Курс ТРА", end_date: "2026-11-10", color: 3 })["structuredContent"]
    expect(updated).to include("title" => "Курс ТРА", "end_date" => "2026-11-10", "color" => 3)

    event = call_tool("add_event", { project_id: id, title: "Группа собрана", date: "2026-11-10", time: "10:00" })["structuredContent"]
    moved = call_tool("update_event", { event_id: event["event_id"], date: "2026-11-09" })["structuredContent"]
    expect(moved).to include("date" => "2026-11-09", "time" => "10:00")

    board = call_tool("list_projects")["structuredContent"]
    expect(board["projects"].map { _1["title"] }).to eq([ "Курс ТРА" ])
    expect(board["projects"].first["events"].size).to eq(3)

    expect(call_tool("delete_event", { event_id: event["event_id"] })["structuredContent"]).to include("deleted" => true)
    expect(call_tool("delete_project", { project_id: id })["structuredContent"]).to include("deleted" => true)
    expect(Project.count).to eq(0)
  end

  it "keeps milestones inside the project dates" do
    outside = call_tool("create_project", {
      title: "X", start_date: "2026-10-01", end_date: "2026-10-05", events: [ { title: "Late", date: "2026-10-09" } ]
    })
    expect(outside["isError"]).to be(true)
    expect(outside["content"].first["text"]).to include("outside the project dates")
    expect(Project.count).to eq(0)

    id = call_tool("create_project", { title: "Y", start_date: "2026-10-01", end_date: "2026-10-10",
                                       events: [ { title: "M", date: "2026-10-08" } ] })["structuredContent"]["project_id"]
    shrink = call_tool("update_project", { project_id: id, end_date: "2026-10-05" })
    expect(shrink["isError"]).to be(true)
    expect(shrink["content"].first["text"]).to include("M")
  end

  it "does not reach other users' projects" do
    other = User.create!(email: "other@example.com", password: "secret-password")
    DemoBoard.fill(other)
    foreign = other.project_connections.first

    result = call_tool("update_project", { project_id: foreign.id, title: "Hacked" })
    expect(result["isError"]).to be(true)
    expect(foreign.project.reload.title).not_to eq("Hacked")
  end
end

RSpec.describe "MCP guide page", type: :request do
  it "shows a browser how to connect and every tool the server lists" do
    expect { get mcp_path, headers: { "Accept" => "text/html,application/xhtml+xml" } }.not_to change(User, :count)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("claude mcp add", mcp_url)
    Mcp::Tools::DEFINITIONS.each { expect(response.body).to include(_1[:name], CGI.escapeHTML(_1[:description])) }
  end

  it "keeps GET for MCP clients without a stream" do
    token = User.create!(email: "dan@example.com", password: "secret-password").regenerate_api_token!
    get mcp_path, headers: { "Accept" => "text/event-stream", "Authorization" => "Bearer #{token}" }
    expect(response).to have_http_status(:method_not_allowed)
  end
end

RSpec.describe "Account page", type: :request do
  it "issues an agent token once and only to registered users" do
    get account_path
    expect(response).to redirect_to(login_path)

    User.create!(email: "dan@example.com", password: "secret-password")
    post login_path, params: { email: "dan@example.com", password: "secret-password" }

    post account_token_path
    token = response.body[/potee_[1-9A-HJ-NP-Za-km-z]{40}/]
    expect(token).to be_present
    expect(User.find_by_api_token(token)).to eq(User.find_by!(email: "dan@example.com"))

    get account_path
    expect(response.body).not_to include(token)
    expect(response.body).to include(%(href="#{mcp_path}"))
  end
end
