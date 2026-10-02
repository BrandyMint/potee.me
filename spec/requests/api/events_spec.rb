require "rails_helper"

RSpec.describe "API events", type: :request do
  let!(:user) { sign_in_anonymously }
  let(:connection) { user.board_connections.first }

  it "creates, moves, renames and deletes an event" do
    post api_project_events_path(connection), params: { event: { at: "2026-10-03T15:30:00Z" } }, as: :json
    expect(response).to have_http_status(:created)
    expect(json).to include("title" => "Some event", "at" => "2026-10-03T15:30:00Z")
    id = json["id"]

    patch api_event_path(id), params: { event: { title: "Moved", at: "2026-10-05T09:00:00Z" } }, as: :json
    expect(json).to include("title" => "Moved", "at" => "2026-10-05T09:00:00Z", "timed" => false)

    patch api_event_path(id), params: { event: { at: "2026-10-05T16:00:00Z", timed: true } }, as: :json
    expect(json).to include("at" => "2026-10-05T16:00:00Z", "timed" => true)

    expect { delete api_event_path(id), as: :json }.to change(Event, :count).by(-1)
  end

  it "does not expose events of projects the user is not connected to" do
    other = User.create!
    DemoBoard.fill(other)
    foreign_event = other.projects.first.events.first

    patch api_event_path(foreign_event), params: { event: { title: "Hacked" } }, as: :json

    expect(response).to have_http_status(:not_found)
  end
end
