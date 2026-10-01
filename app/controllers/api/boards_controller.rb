module Api
  class BoardsController < BaseController
    def show
      render json: board_payload
    end
  end
end
