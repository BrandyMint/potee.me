require "rails_helper"

RSpec.describe User do
  it "finds anonymous users that have not been seen for a while" do
    stale = User.create!(last_seen_at: 40.days.ago)
    User.create!(last_seen_at: 1.day.ago)
    User.create!(email: "dan@example.com", password: "secret-password", last_seen_at: 40.days.ago)

    expect(User.abandoned).to contain_exactly(stale)
  end

  it "normalizes email and validates the password length" do
    user = User.new(email: " Dan@Example.COM ", password: "short")

    expect(user.email).to eq("dan@example.com")
    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end
end
