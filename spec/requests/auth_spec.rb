require "rails_helper"

RSpec.describe "Email sign-up and log-in", type: :request do
  def sign_up(email, password = "secret-password")
    post signup_path, params: { email:, password: }
  end

  def log_in(email, password = "secret-password")
    post login_path, params: { email:, password: }
  end

  describe "sign up" do
    it "turns the anonymous user into an account and keeps the board" do
      anonymous = sign_in_anonymously

      expect { sign_up(" Dan@Example.COM ") }.not_to change(User, :count)

      expect(response).to redirect_to(board_path)
      expect(anonymous.reload).to have_attributes(email: "dan@example.com", anonymous?: false)
      get api_board_path
      expect(json["user"]).to eq("email" => "dan@example.com", "anonymous" => false)
      expect(json["projects"].size).to eq(DemoBoard::SCHEDULE.size)
    end

    it "creates an account with a demo board when there is no session yet" do
      expect { sign_up("new@example.com") }.to change(User, :count).by(1)

      expect(User.find_by!(email: "new@example.com").project_connections.count).to eq(DemoBoard::SCHEDULE.size)
    end

    it "rejects a registered email and a short password" do
      sign_up("taken@example.com")
      delete logout_path

      sign_up("TAKEN@example.com")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(CGI.escapeHTML(I18n.t("flash.email_taken")))

      sign_up("short@example.com", "123")
      expect(response).to have_http_status(:unprocessable_content)
      expect(User.find_by(email: "short@example.com")).to be_nil
    end
  end

  describe "log in" do
    let!(:account) do
      User.create!(email: "dan@example.com", password: "secret-password").tap { DemoBoard.fill(_1) }
    end

    it "merges what the visitor made on the anonymous board, dropping untouched samples" do
      anonymous = sign_in_anonymously
      post api_projects_path, params: { project: { title: "Made before login", started_on: "2026-10-01", finished_on: "2026-10-05" } }, as: :json
      renamed = anonymous.board_connections.first
      patch api_project_path(renamed), params: { project: { title: "Edited sample" } }, as: :json

      log_in("DAN@example.com")

      expect(response).to redirect_to(board_path)
      expect(User.exists?(anonymous.id)).to be(false)
      titles = account.reload.board_connections.map(&:title)
      expect(titles.first(DemoBoard::SCHEDULE.size)).to eq(DemoBoard.titles)
      expect(titles.drop(DemoBoard::SCHEDULE.size)).to contain_exactly("Made before login", "Edited sample")
      expect(Project.where(title: "Made before login").sole.owner).to eq(account)
    end

    it "rejects a wrong password" do
      log_in("dan@example.com", "wrong-password")

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(CGI.escapeHTML(I18n.t("flash.wrong_credentials")))
    end

    it "logs out into a new anonymous board" do
      log_in("dan@example.com")
      delete logout_path
      expect(response).to redirect_to(root_path)

      expect { get board_path }.to change(User.anonymous, :count).by(1)
    end
  end

  describe "password reset" do
    let!(:account) { User.create!(email: "dan@example.com", password: "secret-password") }

    it "emails a link that sets a new password" do
      expect {
        perform_enqueued_jobs { post passwords_path, params: { email: "dan@example.com" } }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(response).to redirect_to(login_path)

      letter = ActionMailer::Base.deliveries.last
      expect(letter.to).to eq([ "dan@example.com" ])
      token = letter.text_part.body.to_s[%r{/passwords/([^/\s]+)/edit}, 1]

      get edit_password_path(token)
      expect(response).to have_http_status(:ok)

      patch password_path(token), params: { password: "brand-new-password" }
      expect(response).to redirect_to(board_path)
      expect(account.reload.authenticate("brand-new-password")).to be_truthy

      get edit_password_path(token)
      expect(response).to redirect_to(new_password_path)
    end

    it "does not reveal whether an email is registered" do
      expect {
        perform_enqueued_jobs { post passwords_path, params: { email: "nobody@example.com" } }
      }.not_to change(ActionMailer::Base.deliveries, :count)
      expect(response).to redirect_to(login_path)
    end
  end
end
