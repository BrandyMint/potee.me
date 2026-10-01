module BoardHelpers
  # Visiting the board creates the anonymous session user (with its demo board).
  def sign_in_anonymously
    get board_path
    User.order(:id).last
  end

  def json
    response.parsed_body
  end
end

RSpec.configure do |config|
  config.include BoardHelpers, type: :request
  config.include ActiveJob::TestHelper, type: :request
end
