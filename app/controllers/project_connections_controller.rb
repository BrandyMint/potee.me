class ProjectConnectionsController < ApplicationController
  inherit_resources

  respond_to :json, :html

  def show
    @shared_project = ProjectConnection.where(share_key: params[:id]).first!

    if current_user.projects.exists? @shared_project.project
      redirect_to projects_path
    else
      @projects = current_user_projects

      render 'projects/index'
    end
  end
end
