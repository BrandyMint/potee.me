require "rails_helper"

RSpec.describe "Admin", type: :request do
  around do |example|
    original = ENV["ADMIN_EMAILS"]
    ENV["ADMIN_EMAILS"] = "boss@example.com, other@example.com"
    example.run
  ensure
    ENV["ADMIN_EMAILS"] = original
  end

  def log_in(email)
    User.find_or_create_by!(email:) { _1.password = "secret-password" }.tap { DemoBoard.fill(_1) }
    post login_path, params: { email:, password: "secret-password" }
  end

  it "is hidden from anonymous visitors and regular users" do
    sign_in_anonymously
    get admin_root_path
    expect(response).to have_http_status(:not_found)

    log_in("someone@example.com")
    get admin_root_path
    expect(response).to have_http_status(:not_found)
  end

  it "lets listed admins browse every section" do
    log_in("BOSS@example.com")
    project = Project.first

    [ admin_users_path, admin_projects_path, admin_events_path, admin_project_connections_path,
     admin_project_path(project), admin_user_path(project.owner), admin_users_path(search: "registered:") ].each do |path|
      get path
      expect(response).to have_http_status(:ok), "#{path} → #{response.status}"
    end
    get admin_user_path(project.owner)
    expect(response.body).not_to include("password_digest")
  end
end
