require "rails_helper"

RSpec.describe "API dashboard", type: :request do
  let!(:user) { sign_in_anonymously }

  it "saves the view state" do
    patch api_dashboard_path, params: { dashboard: { pixels_per_day: 20, current_date: "2026-11-01T12:00:00Z", scroll_top: 120 } }, as: :json

    expect(response).to have_http_status(:ok)
    expect(json).to eq("pixels_per_day" => 20, "current_date" => "2026-11-01T12:00:00Z", "scroll_top" => 120)
  end

  it "rejects zoom outside the supported range" do
    patch api_dashboard_path, params: { dashboard: { pixels_per_day: 1000 } }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
  end
end
