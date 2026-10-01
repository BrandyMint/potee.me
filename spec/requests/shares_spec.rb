require "rails_helper"

RSpec.describe "Sharing", type: :request do
  it "adds the shared project to the visitor's board once" do
    owner = User.create!
    DemoBoard.fill(owner)
    shared = owner.project_connections.first

    sign_in_anonymously
    visitor = User.last

    expect { get share_path(shared.share_key) }.to change { visitor.project_connections.count }.by(1)
    joined = visitor.project_connections.find_by!(project: shared.project)
    expect(response).to redirect_to(board_path(focus: joined.id))
    expect(joined).not_to be_owner

    expect { get share_path(shared.share_key) }.not_to change { visitor.project_connections.count }
  end

  it "keeps the project when a non-owner removes it from their board" do
    owner = User.create!
    DemoBoard.fill(owner)
    shared = owner.project_connections.first
    sign_in_anonymously
    get share_path(shared.share_key)
    joined = User.last.project_connections.find_by!(project: shared.project)

    expect { delete api_project_path(joined), as: :json }.not_to change(Project, :count)
  end
end
