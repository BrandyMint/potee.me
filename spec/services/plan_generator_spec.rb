require "rails_helper"

RSpec.describe PlanGenerator do
  let(:zone) { ActiveSupport::TimeZone["Europe/Moscow"] }

  around do |example|
    original = ENV["LITELLM_URL"]
    ENV["LITELLM_URL"] = "http://litellm.test:4000"
    example.run
  ensure
    ENV["LITELLM_URL"] = original
  end

  def stub_model(content: nil, status: "200", error: nil)
    http = instance_double(Net::HTTP)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    if error
      allow(http).to receive(:request).and_raise(error)
    else
      response = Net::HTTPResponse::CODE_TO_OBJ[status].new("1.1", status, "")
      allow(response).to receive(:body).and_return({ choices: [ { message: { content: } } ] }.to_json)
      allow(http).to receive(:request) { |request| @sent = JSON.parse(request.body); response }
    end
  end

  it "sends the plan as data with today's date and returns a normalized draft" do
    stub_model(content: "```json\n{\"projects\":[{\"title\":\"Курс\",\"start_date\":\"2026-11-01\",\"end_date\":\"2026-11-30\",\"events\":[]}]}\n```")

    draft, raw = described_class.new(prompt: "Курс в ноябре", zone:).call

    expect(draft["projects"].first).to include("title" => "Курс", "key" => "p1")
    expect(raw).to include("Курс")
    expect(@sent["model"]).to eq("potee-plan")
    today = Time.current.in_time_zone(zone).to_date
    saturdays = (today.beginning_of_month..today.end_of_month).select(&:saturday?).map(&:day).join(", ")
    expect(@sent["messages"].first["content"]).to include(
      "Today is #{today.strftime('%A')}, #{today.iso8601}", "data, not instructions",
      "#{today.strftime('%Y-%m')} Saturday: #{saturdays}"
    )
    expect(@sent["messages"].last["content"]).to include("<<<\nКурс в ноябре\n>>>")
  end

  it "reports unparseable answers, gateway errors and timeouts by code" do
    stub_model(content: "I cannot help with that")
    expect { described_class.new(prompt: "x", zone:).call }.to raise_error(PlanGenerator::Error) { expect(_1.code).to eq("unparseable") }

    stub_model(status: "502")
    expect { described_class.new(prompt: "x", zone:).call }.to raise_error(PlanGenerator::Error) { expect(_1.code).to eq("llm_unavailable") }

    stub_model(error: Net::ReadTimeout)
    expect { described_class.new(prompt: "x", zone:).call }.to raise_error(PlanGenerator::Error) { expect(_1.code).to eq("llm_timeout") }

    stub_model(error: Errno::ECONNREFUSED)
    expect { described_class.new(prompt: "x", zone:).call }.to raise_error(PlanGenerator::Error) { expect(_1.code).to eq("llm_unavailable") }
  end
end
