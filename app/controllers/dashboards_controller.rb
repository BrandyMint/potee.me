class DashboardsController < ApplicationController

  respond_to :js, :json, :html

  def read
    render :json => current_user.dashboard.to_json
  end

  def update
    dashboard = current_user.dashboard
    dashboard.update_attributes(pixels_per_day: params[:pixels_per_day], current_date: params[:current_date])
    render :json => dashboard.to_json
  end
end