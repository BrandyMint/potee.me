require "rails_helper"

RSpec.describe "API projects", type: :request do
  let!(:user) { sign_in_anonymously }

  it "creates a project for the current user" do
    post api_projects_path, params: { project: { title: "New one", started_on: "2026-10-01", finished_on: "2026-10-07", color_index: 4 } }, as: :json

    expect(response).to have_http_status(:created)
    expect(json).to include("title" => "New one", "started_on" => "2026-10-01", "finished_on" => "2026-10-07", "color_index" => 4, "owner" => true)
    expect(json["share_url"]).to match(%r{/share/\w+\z})
  end

  it "rejects a finish before the start" do
    post api_projects_path, params: { project: { title: "Bad", started_on: "2026-10-07", finished_on: "2026-10-01" } }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(json["errors"]).to have_key("finished_on")
  end

  it "updates shared fields on the project and colour on the connection" do
    connection = user.board_connections.first
    patch api_project_path(connection), params: { project: { title: "Renamed", finished_on: "2030-01-01", color_index: 9 } }, as: :json

    expect(response).to have_http_status(:ok)
    expect(connection.project.reload).to have_attributes(title: "Renamed", finished_on: Date.new(2030, 1, 1))
    expect(connection.reload.color_index).to eq(9)
  end

  it "reorders the board" do
    ids = user.board_connections.map(&:id).reverse
    patch reorder_api_projects_path, params: { ids: }, as: :json

    expect(response).to have_http_status(:no_content)
    expect(user.board_connections.map(&:id)).to eq(ids)
  end

  it "deleting the owner's row deletes the project" do
    connection = user.board_connections.first

    expect { delete api_project_path(connection), as: :json }.to change(Project, :count).by(-1)
    expect(response).to have_http_status(:no_content)
  end

  it "does not let one user touch another user's rows" do
    other = User.create!
    DemoBoard.fill(other)
    foreign = other.project_connections.first

    patch api_project_path(foreign), params: { project: { title: "Hacked" } }, as: :json

    expect(response).to have_http_status(:not_found)
    expect(foreign.project.reload.title).not_to eq("Hacked")
  end
end
