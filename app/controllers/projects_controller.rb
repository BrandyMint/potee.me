class ProjectsController < ApplicationController
  ProjectSlice = [:title, :started_at, :finish_at]
  ProjectConnectionSlice = [:position, :color_index]

  respond_to :js, :json, :html

  def index
    @projects = current_user.project_connections.includes(:project, :events).order(:position)
  end

  def create
    @project = current_user.owned_projects.create! project_params

    @project_connection = ProjectConnection.create! project_connection_params.merge project: @project, user: current_user

    render json: @project_connection
  end

  def update
    @project_connection = current_user.project_connections.
      where(project_id: params[:project][:project_id]).first

    raise ActiveRecord::RecordNotFound unless @project_connection

    @project_connection.project.update_attributes! project_params
    @project_connection.update_attributes! project_connection_params

    render json: @project_connection.reload
  end

  def destroy
    @project_connection = current_user.project_connections.find params[:project][:id]

    @project_connection.destroy
  end

  protected

  def project_params
    params[:project].slice *ProjectSlice
  end

  def project_connection_params
    params[:project].slice *ProjectConnectionSlice
  end

  def end_of_association_chain
    current_user.owned_projects
  end

  def begin_of_association_chain
    current_user
  end
end
