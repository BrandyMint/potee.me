require "rails_helper"

RSpec.describe "Account settings: language, region and days off", type: :request do
  it "detects the region and language at sign-up from the browser" do
    post signup_path, params: { email: "kz@example.com", password: "secret-password", time_zone: "Asia/Almaty" },
                      headers: { "Accept-Language" => "en-US,en;q=0.9" }

    expect(User.find_by!(email: "kz@example.com")).to have_attributes(region: "KZ", locale: "en", dim_days_off: true)
  end

  it "falls back to the language region without a time zone" do
    post signup_path, params: { email: "ru@example.com", password: "secret-password" }, headers: { "Accept-Language" => "ru" }

    expect(User.find_by!(email: "ru@example.com")).to have_attributes(region: "RU", locale: "ru")
  end

  it "sends the calendar of the account's region with the board" do
    post signup_path, params: { email: "dan@example.com", password: "secret-password", time_zone: "Europe/Moscow" }

    get api_board_path
    expect(json["calendar"]).to include("region" => "RU", "dim" => true, "weekend" => [ 0, 6 ])
    expect(json["calendar"]["holidays"]).to include("#{Date.current.year}-01-02")
  end

  it "guesses the region of an anonymous board from the browser language" do
    get api_board_path, headers: { "Accept-Language" => "de-DE,de;q=0.9" }

    expect(json["calendar"]).to include("region" => "DE")
    expect(json["calendar"]["holidays"]).not_to be_empty
  end

  it "changes the settings on the account page and switches the interface language" do
    post signup_path, params: { email: "dan@example.com", password: "secret-password", time_zone: "Europe/Moscow" }

    patch account_path, params: { user: { locale: "en", region: "", dim_days_off: "0" } }

    expect(response).to redirect_to(account_path)
    expect(User.find_by!(email: "dan@example.com")).to have_attributes(locale: "en", region: nil, dim_days_off: false)
    get account_path, headers: { "Accept-Language" => "ru" }
    expect(response.body).to include("Settings saved.")
    get api_board_path
    expect(json["calendar"]).to include("region" => nil, "dim" => false, "holidays" => [])
  end

  it "takes the clock from the account, otherwise from the language" do
    get api_board_path, headers: { "Accept-Language" => "ru" }
    expect(json["time_format"]).to eq("24h")
    get api_board_path, headers: { "Accept-Language" => "en" }
    expect(json["time_format"]).to eq("12h")

    post signup_path, params: { email: "dan@example.com", password: "secret-password" }, headers: { "Accept-Language" => "en" }
    patch account_path, params: { user: { time_format: "24h" } }
    get api_board_path
    expect(json["time_format"]).to eq("24h")

    patch account_path, params: { user: { time_format: "13h" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "rejects an unknown region" do
    post signup_path, params: { email: "dan@example.com", password: "secret-password" }

    patch account_path, params: { user: { region: "XX" } }

    expect(response).to have_http_status(:unprocessable_content)
  end
end
