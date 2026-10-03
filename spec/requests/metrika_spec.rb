require "rails_helper"

RSpec.describe "Yandex Metrika", type: :request do
  it "is only in production" do
    get root_path
    expect(response.body).not_to include("mc.yandex.ru")
  end

  context "in production" do
    before { allow(Rails.env).to receive(:production?).and_return(true) }

    it "counts the landing page with goals and without Webvisor" do
      get root_path
      expect(response.body).to include("mc.yandex.ru/metrika/tag.js", "113370026", "webvisor:false", 'data-metrika-goal="start_board"')
    end

    it "stays off pages whose URL carries a password reset token" do
      get new_password_path
      expect(response.body).not_to include("mc.yandex.ru")
    end
  end
end
