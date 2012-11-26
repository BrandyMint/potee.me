class DashboardsController < ApplicationController

  respond_to :js, :json, :html

  def read
    render :json => current_user.dashboard.to_json
  end

  def update
    dashboard = current_user.dashboard
    dashboard.update_attributes(pixel_scale: params[:pixel_scale], current_date: params[:current_date])
    render :json => dashboard.to_json
  end    
end
