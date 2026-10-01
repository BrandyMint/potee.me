module Api
  class BaseController < ApplicationController
    include CurrentUser

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "not_found" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { errors: error.record.errors.to_hash(true) }, status: :unprocessable_content
    end

    rescue_from ActionController::ParameterMissing do |error|
      render json: { error: error.message }, status: :bad_request
    end
  end
end
