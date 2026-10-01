# Opening a share link adds the project to the visitor's board.
class SharesController < ApplicationController
  include CurrentUser

  def show
    shared = ProjectConnection.find_by!(share_key: params[:share_key])
    shared.project.edited! unless shared.user == current_user
    connection = current_user.project_connections.find_or_create_by!(project: shared.project) do |new_connection|
      new_connection.color_index = current_user.next_color_index
      new_connection.position = -1
    end
    redirect_to board_path(focus: connection.id)
  end
end
