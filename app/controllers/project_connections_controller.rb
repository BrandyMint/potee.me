class ProjectConnectionsController < ApplicationController
  inherit_resources

  respond_to :json

  def show
    @shared_project = ProjectConnection.where(share_key: params[:id]).first!

    if current_user.projects.include?(pc.project)
      redirect_to projects_path 
    else
      @projects = current_user_projects

      render 'projects/index'
    end
  end
end
