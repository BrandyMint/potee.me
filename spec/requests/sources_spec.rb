require "rails_helper"

RSpec.describe "Traffic attribution", type: :request do
  it "gives the board the UTM tags of the first page of the visit" do
    get root_path(utm_source: "Telegram", utm_medium: "community", utm_campaign: "potee-direction-check", utm_content: "club-chat", ref: "x"),
        headers: { "Referer" => "https://t.me/agents?start=secret" }
    get root_path(utm_source: "later")
    get board_path

    expect(User.last.attribution).to eq(
      "landingPage" => "/", "referrer" => "https://t.me/agents",
      "utm" => { "source" => "telegram", "medium" => "community", "campaign" => "potee-direction-check", "content" => "club-chat" }
    )
  end

  it "drops invalid values and ignores ?ref=" do
    get root_path(utm_source: "Иван Петров", utm_medium: "dm", ref: "club")
    get board_path
    expect(User.last.attribution).to eq("landingPage" => "/", "utm" => { "medium" => "dm" })
  end

  it "marks boards that start from a share link" do
    owner = sign_in_anonymously
    key = owner.project_connections.first.share_key
    reset!

    get share_path(key)
    follow_redirect!
    expect(User.last.attribution["utm"]).to eq("source" => "potee", "medium" => "share")
  end

  it "keeps the tags for a sign-up without a board" do
    get root_path(utm_source: "pismenny-ru", utm_medium: "referral")
    post signup_path, params: { email: "dan@example.com", password: "secret-password" }
    expect(User.find_by!(email: "dan@example.com").utm(:source)).to eq("pismenny-ru")
  end

  it "ignores the site's own pages as referrers" do
    get root_path, headers: { "Referer" => "http://www.example.com/projects" }
    get board_path
    expect(User.last.attribution).to eq("landingPage" => "/")
  end
end

RSpec.describe SourceReport do
  def tagged(source, campaign) = { "utm" => { "source" => source, "medium" => "community", "campaign" => campaign } }

  it "counts the funnel by source and week" do
    club = User.create!(attribution: tagged("telegram", "potee-direction-check"), last_seen_at: 8.days.from_now)
    DemoBoard.fill(club)
    club.owned_projects.first.edited!
    User.create!(attribution: tagged("telegram", "other"), email: "dan@example.com", password: "secret-password")
    User.create!(last_seen_at: Time.current)
    friend = User.create!(attribution: { "utm" => { "source" => "potee", "medium" => "share" } })
    friend.project_connections.create!(project: club.owned_projects.first)

    rows = described_class.new.totals.index_by(&:tag)
    expect(rows["telegram"].to_h).to include(came: 2, activated: 1, returned: 1, registered: 1, joined: 0, shared: 1)
    expect(rows["potee"].to_h).to include(came: 1, activated: 0, joined: 1)
    expect(rows[nil].to_h).to include(came: 1, activated: 0)
    expect(described_class.new(by: "campaign").totals.to_h { [ _1.tag, _1.came ] }).to eq("potee-direction-check" => 1, "other" => 1, nil => 2)
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

    User.create!(email: "boss@example.com", password: "secret-password", attribution: { "utm" => { "source" => "telegram" } })
    post login_path, params: { email: "boss@example.com", password: "secret-password" }
    get admin_sources_path(weeks: 4, by: "source")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Источники", "telegram")
  end
end
