class ProjectConnectionsController < ApplicationController
  inherit_resources

  respond_to :json

  def show
    project = Project.find_by_share_key params[:id]
    @shared_project = SharedProject.new project, params[:id]

    @projects = current_user_projects

    render 'projects/index'
  end
end
