require "rails_helper"

RSpec.describe "Traffic sources", type: :request do
  it "gives the board the source of the first page of the visit" do
    get root_path(ref: "Club"), headers: { "Referer" => "https://t.me/agents" }
    get root_path(ref: "later")
    get board_path

    expect(User.last).to have_attributes(source: "club", referrer: "t.me")
  end

  it "marks boards that start from a share link" do
    owner = sign_in_anonymously
    key = owner.project_connections.first.share_key
    reset!

    get share_path(key)
    follow_redirect!
    expect(User.last).to have_attributes(source: "share", referrer: nil)
  end

  it "keeps the source for a sign-up without a board" do
    get root_path(utm_source: "pismenny")
    post signup_path, params: { email: "dan@example.com", password: "secret-password" }
    expect(User.find_by!(email: "dan@example.com").source).to eq("pismenny")
  end

  it "ignores the site's own pages as referrers" do
    get root_path, headers: { "Referer" => "http://www.example.com/projects" }
    get board_path
    expect(User.last).to have_attributes(source: nil, referrer: nil)
  end
end

RSpec.describe SourceReport do
  it "counts the funnel by source and week" do
    club = User.create!(source: "club", last_seen_at: 8.days.from_now)
    DemoBoard.fill(club)
    club.owned_projects.first.edited!
    User.create!(source: "club", email: "dan@example.com", password: "secret-password")
    User.create!(last_seen_at: Time.current)
    friend = User.create!(source: "share")
    friend.project_connections.create!(project: club.owned_projects.first)

    rows = described_class.new.by_source.index_by(&:source)
    expect(rows["club"].to_h).to include(came: 2, activated: 1, returned: 1, registered: 1, joined: 0, shared: 1)
    expect(rows["share"].to_h).to include(came: 1, activated: 0, joined: 1)
    expect(rows[nil].to_h).to include(came: 1, activated: 0)
    expect(described_class.new.by_week.map(&:week).uniq).to eq([ Time.current.in_time_zone("Europe/Moscow").to_date.beginning_of_week ])
  end
end

RSpec.describe "Admin sources report", type: :request do
  around do |example|
    original = ENV["ADMIN_EMAILS"]
    ENV["ADMIN_EMAILS"] = "boss@example.com"
    example.run
  ensure
    ENV["ADMIN_EMAILS"] = original
  end

  it "shows sources to admins only" do
    get admin_sources_path
    expect(response).to have_http_status(:not_found)

    User.create!(email: "boss@example.com", password: "secret-password", source: "club")
    post login_path, params: { email: "boss@example.com", password: "secret-password" }
    get admin_sources_path(weeks: 4)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Источники", "club")
  end
end
