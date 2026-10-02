require "rails_helper"

RSpec.describe "API plan requests (FT-001)", type: :request do
  around do |example|
    original = ENV.to_h.slice("PLAN_FROM_TEXT_ENABLED", "LITELLM_URL")
    ENV["PLAN_FROM_TEXT_ENABLED"] = "1"
    ENV["LITELLM_URL"] = "fake"
    example.run
  ensure
    ENV.delete("PLAN_FROM_TEXT_ENABLED")
    ENV.delete("LITELLM_URL")
    ENV.update(original)
  end

  def sign_up
    post signup_path, params: { email: "dan@example.com", password: "secret-password" }
    User.find_by!(email: "dan@example.com")
  end

  def create_plan(prompt = "Запуск курса к 1 декабря")
    post api_plan_requests_path, params: { prompt:, timezone: "Europe/Moscow" }, as: :json
  end

  it "is only for registered users" do
    sign_in_anonymously
    create_plan
    expect(response).to have_http_status(:forbidden)
    expect(json).to eq("error" => "sign_up_required")
  end

  it "is hidden when the feature is off" do
    ENV.delete("PLAN_FROM_TEXT_ENABLED")
    sign_up
    create_plan
    expect(response).to have_http_status(:not_found)
    get api_board_path
    expect(json["features"]).to eq("plan_from_text" => false)
  end

  it "generates a draft in the background and applies the chosen projects" do
    user = sign_up
    get api_board_path
    expect(json["features"]).to eq("plan_from_text" => true)

    create_plan
    expect(response).to have_http_status(:accepted)
    id = json["id"]
    expect(json["status"]).to eq("pending")

    perform_enqueued_jobs
    get api_plan_request_path(id)
    expect(json["status"]).to eq("ready")
    projects = json["draft"]["projects"]
    expect(projects.map { _1["key"] }).to eq(%w[p1 p2])

    before = user.project_connections.count
    post apply_api_plan_request_path(id), params: { project_keys: [ "p2" ] }, as: :json
    expect(response).to have_http_status(:created)
    expect(json["projects"].map { _1["title"] }).to eq([ "Запуск" ])
    expect(json["projects"].first["events"].map { _1["title"] }).to eq(%w[Старт Итоги])
    expect(user.board_connections.last.title).to eq("Запуск")
    expect(user.project_connections.count).to eq(before + 1)
    expect(PlanRequest.find(id)).to be_applied

    post apply_api_plan_request_path(id), params: { project_keys: [ "p1" ] }, as: :json
    expect(response).to have_http_status(:conflict)
  end

  it "keeps a failed generation visible with its error code" do
    sign_up
    allow_any_instance_of(PlanGenerator).to receive(:call).and_raise(PlanGenerator::Error.new("llm_timeout"))
    create_plan
    perform_enqueued_jobs

    get api_plan_request_path(json["id"])
    expect(json).to include("status" => "failed", "error" => "llm_timeout")
  end

  it "marks a generation interrupted by a restart as failed" do
    user = sign_up
    plan = user.plan_requests.create!(prompt: "x", created_at: 5.minutes.ago)

    get api_plan_request_path(plan)
    expect(json).to include("status" => "failed", "error" => "interrupted")
  end

  it "allows one generation at a time and 20 a day" do
    user = sign_up
    create_plan
    create_plan
    expect(response).to have_http_status(:too_many_requests)
    expect(json).to eq("error" => "in_progress")

    perform_enqueued_jobs
    (PlanRequest::DAILY_LIMIT - 1).times { user.plan_requests.create!(prompt: "x", status: :discarded) }
    create_plan
    expect(json).to eq("error" => "daily_limit")
  end

  it "rejects empty and too long plans" do
    sign_up
    create_plan("")
    expect(response).to have_http_status(:bad_request)
    create_plan("x" * (PlanRequest::MAX_PROMPT_LENGTH + 1))
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "discards a draft and hides other users' requests" do
    sign_up
    create_plan
    id = json["id"]
    perform_enqueued_jobs
    post discard_api_plan_request_path(id), as: :json
    expect(PlanRequest.find(id)).to be_discarded

    other = User.create!(email: "other@example.com", password: "secret-password")
    foreign = other.plan_requests.create!(prompt: "x")
    get api_plan_request_path(foreign)
    expect(response).to have_http_status(:not_found)
  end
end
