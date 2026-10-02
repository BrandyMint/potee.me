module Admin
  class PlanRequestsController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
      %w[index show].include?(name.to_s) && super
    end
  end
end
