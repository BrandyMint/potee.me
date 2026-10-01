# Serves the page the React board is mounted on, with its initial state inline.
class BoardsController < ApplicationController
  include CurrentUser

  def show
    @board = board_payload
  end
end
