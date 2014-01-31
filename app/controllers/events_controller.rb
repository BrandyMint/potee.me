class EventsController < ApplicationController
  inherit_resources

  before_filter :reset_params, only: :create

  respond_to :json

  private

  def reset_params
    params[:event][:project_id] = ProjectConnection.find(params[:event][:project_id]).project_id
  end
end
