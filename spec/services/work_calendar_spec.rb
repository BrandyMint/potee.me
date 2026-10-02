require "rails_helper"

RSpec.describe WorkCalendar do
  it "uses the production calendar with moved days off and working Saturdays" do
    calendar = described_class.for("RU").as_board_json(today: Date.new(2025, 6, 1))

    expect(calendar[:holidays]).to include("2025-01-08", "2025-05-02", "2025-11-03")
    expect(calendar[:workdays]).to include("2025-11-01")
  end

  it "uses public holidays elsewhere and the local weekend" do
    expect(described_class.for("DE").as_board_json(today: Date.new(2026, 6, 1))[:holidays]).to include("2026-12-25")
    expect(described_class.for("IL").as_board_json[:weekend]).to eq([ 5, 6 ])
  end

  it "dims only weekends without a known region" do
    expect(described_class.for("ZZ").as_board_json).to include(region: nil, weekend: [ 0, 6 ], holidays: [], workdays: [])
  end

  it "detects the region by time zone first, then by language" do
    expect(described_class.detect(time_zone: "Europe/Minsk", accept_language: "ru-RU")).to eq("BY")
    expect(described_class.detect(time_zone: "Asia/Bangkok")).to eq("TH")
    expect(described_class.detect(time_zone: "Europe/Oslo")).to eq("NO")
    expect(described_class.detect(time_zone: "America/Chicago")).to eq("US")
    expect(described_class.detect(time_zone: "Europe/Kiev")).to eq("UA")
    expect(described_class.detect(time_zone: "Asia/Novosibirsk")).to eq("RU")
    expect(described_class.detect(time_zone: "Nowhere/City", accept_language: "en-GB,en")).to eq("GB")
    expect(described_class.detect(accept_language: "en")).to be_nil
  end
end
