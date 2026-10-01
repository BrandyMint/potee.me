# Administrate back office at /admin. Only logged-in users whose email is in
# ADMIN_EMAILS (comma separated) get in; everyone else sees a 404.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include CurrentUser

    before_action :authenticate_admin

    private

    def default_sorting_attribute
      :id
    end

    def default_sorting_direction
      :desc
    end

    def authenticate_admin
      raise ActionController::RoutingError, "Not Found" unless admin?(session_user)
    end

    def admin?(user)
      return false if user.nil? || user.anonymous?

      ENV.fetch("ADMIN_EMAILS", "").split(",").map { _1.strip.downcase }.include?(user.email)
    end
  end
end
