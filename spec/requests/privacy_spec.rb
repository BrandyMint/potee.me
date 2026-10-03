require "rails_helper"

RSpec.describe "Privacy page", type: :request do
  it "describes the data in Russian and English without creating a board" do
    expect { get privacy_path }.not_to change(User, :count)
    expect(response.body).to include("Яндекс Метрика", "danil@pismenny.ru")

    get privacy_path, headers: { "Accept-Language" => "en" }
    expect(response.body).to include("Yandex Metrika", "OpenRouter")
  end

  it "is linked from the landing and sign-up pages" do
    get root_path
    expect(response.body).to include(%(href="#{privacy_path}"))
    get signup_path
    expect(response.body).to include(%(href="#{privacy_path}"))
  end
end
