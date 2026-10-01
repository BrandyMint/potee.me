require "rails_helper"

RSpec.describe "Board", type: :request do
  it "creates an anonymous user with a demo board on the first visit" do
    expect { get board_path }.to change(User, :count).by(1)

    expect(response).to have_http_status(:ok)
    user = User.last
    expect(user).to be_anonymous
    expect(user.dashboard).to be_present
    expect(user.project_connections.count).to eq(DemoBoard::PROJECTS.size)
  end

  it "keeps the same user for the session" do
    get board_path
    expect { get api_board_path }.not_to change(User, :count)

    expect(json["projects"].map { _1["title"] }).to eq(DemoBoard::PROJECTS.map { _1[:title] })
    expect(json["dashboard"]).to include("pixels_per_day" => 150, "scroll_top" => 0)
    expect(json["projects"].first).to include("owner" => true, "events" => be_an(Array))
  end

  it "does not create users on the landing page" do
    expect { get root_path }.not_to change(User, :count)
    expect(response).to have_http_status(:ok)
  end
end
