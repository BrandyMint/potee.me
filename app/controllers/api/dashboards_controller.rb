module Api
  class DashboardsController < BaseController
    def update
      dashboard = current_user.dashboard
      dashboard.update!(params.expect(dashboard: %i[pixels_per_day current_date scroll_top]))
      render json: dashboard.as_board_json
    end
  end
end
