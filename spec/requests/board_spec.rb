require "rails_helper"

RSpec.describe "Board", type: :request do
  it "creates an anonymous user with a demo board on the first visit" do
    expect { get board_path }.to change(User, :count).by(1)

    expect(response).to have_http_status(:ok)
    user = User.last
    expect(user).to be_anonymous
    expect(user.dashboard).to be_present
    expect(user.project_connections.count).to eq(DemoBoard::SCHEDULE.size)
  end

  it "marks the board edited once the visitor has a project of their own" do
    get api_board_path
    expect(json["user"]).to include("anonymous" => true, "edited" => false)

    post api_projects_path, params: { project: { title: "Mine", started_on: "2026-10-01", finished_on: "2026-10-07" } }, as: :json
    get api_board_path
    expect(json["user"]).to include("edited" => true)
  end

  it "keeps the same user for the session" do
    get board_path
    expect { get api_board_path }.not_to change(User, :count)

    expect(json["projects"].map { _1["title"] }).to eq(DemoBoard.titles)
    expect(json["dashboard"]).to include("pixels_per_day" => 150, "scroll_top" => 0)
    expect(json["projects"].first).to include("owner" => true, "events" => be_an(Array))
  end

  it "does not create users on the landing page" do
    expect { get root_path }.not_to change(User, :count)
    expect(response).to have_http_status(:ok)
  end

  it "shows the landing page to an anonymous board" do
    sign_in_anonymously
    get root_path
    expect(response).to have_http_status(:ok)
  end

  it "sends a logged-in user from the landing page to the board" do
    post signup_path, params: { email: "dan@example.com", password: "secret-password" }
    get root_path
    expect(response).to redirect_to(board_path)
  end
end

RSpec.describe "Language", type: :request do
  it "is Russian by default and English for English browsers" do
    get root_path
    expect(response.body).to include('lang="ru"', I18n.t("welcome.get_started", locale: :ru))

    get root_path, headers: { "Accept-Language" => "en-US,en;q=0.9,ru;q=0.5" }
    expect(response.body).to include('lang="en"', "Get started")
  end

  it "fills the demo board in the visitor's language" do
    get board_path, headers: { "Accept-Language" => "en" }
    get api_board_path, headers: { "Accept-Language" => "en" }

    expect(json["locale"]).to eq("en")
    expect(json["projects"].first["title"]).to eq("Learn Scala")
  end
end
