require "rails_helper"

RSpec.describe PlanNormalizer do
  subject(:normalize) { described_class.new(today: Date.new(2026, 10, 2)).method(:call) }

  def plan(*projects) = { "projects" => projects }

  it "keeps a valid plan, numbers projects and fills default times" do
    result = normalize.(plan({ "title" => "Лендинг", "start_date" => "2026-10-02", "end_date" => "2026-10-20",
                               "events" => [ { "title" => "Готов", "date" => "2026-10-20", "time" => nil } ] }))

    expect(result["projects"]).to eq([
      { "title" => "Лендинг", "start_date" => "2026-10-02", "end_date" => "2026-10-20", "adjusted" => false,
        "events" => [ { "title" => "Готов", "date" => "2026-10-20", "time" => "12:00" } ], "key" => "p1" }
    ])
  end

  it "stretches a project to cover its milestones and swaps inverted dates" do
    result = normalize.(plan({ "title" => "X", "start_date" => "2026-10-10", "end_date" => "2026-10-05",
                               "events" => [ { "title" => "Поздно", "date" => "2026-10-12", "time" => "19:00" } ] }))

    expect(result["projects"].first).to include("start_date" => "2026-10-05", "end_date" => "2026-10-12", "adjusted" => true)
  end

  it "drops broken milestones and projects, and dates far from today" do
    result = normalize.(plan(
      { "title" => "Битый", "start_date" => "nope", "end_date" => "2026-13-40", "events" => [] },
      { "title" => "Ок", "start_date" => "2026-10-02", "end_date" => "2026-10-03",
        "events" => [ { "title" => "Мусор", "date" => "завтра" }, { "title" => "Далеко", "date" => "2031-01-01" } ] }
    ))

    expect(result["projects"].map { _1["title"] }).to eq([ "Ок" ])
    expect(result["projects"].first["events"]).to eq([])
  end

  it "caps sizes and fills empty titles" do
    many = Array.new(8) { { "title" => "", "start_date" => "2026-10-02", "end_date" => "2026-10-09",
                             "events" => Array.new(15) { { "title" => "", "date" => "2026-10-05" } } } }
    result = normalize.(plan(*many))

    expect(result["projects"].size).to eq(6)
    expect(result["projects"].first["events"].size).to eq(12)
    expect(result["projects"].first["title"]).to eq("Проект")
    expect(result["projects"].first["events"].first["title"]).to eq("Событие")
  end

  it "returns nil when nothing usable is left" do
    expect(normalize.(nil)).to be_nil
    expect(normalize.({ "projects" => [] })).to be_nil
    expect(normalize.({ "text" => "sorry" })).to be_nil
  end
end
