# Admin report: new boards by traffic source and week (see SourceReport).
module Admin
  class SourcesController < Admin::ApplicationController
    def index
      @report = SourceReport.new(weeks: params.fetch(:weeks, 8).to_i.clamp(1, 52), by: params[:by])
    end
  end
end
