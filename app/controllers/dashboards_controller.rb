class DashboardsController < ApplicationController

  respond_to :json

  def read
    render json: current_user.dashboard.to_json
  end

  def update
    dashboard = current_user.dashboard
    dashboard.update_attributes params.slice :pixels_per_day, :current_date, :scroll_top
    render json: dashboard.to_json
  end
end
