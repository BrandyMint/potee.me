class GeneratePlanJob < ApplicationJob
  queue_as :default

  def perform(plan_request_id)
    request = PlanRequest.find_by(id: plan_request_id)
    return unless request&.pending?

    started = Time.current
    draft, raw = PlanGenerator.new(prompt: request.prompt, zone: request.zone).call
    request.update!(status: :ready, draft:, raw_response: raw, completed_at: Time.current)
    log(request, started)
  rescue PlanGenerator::Error => error
    request&.update!(status: :failed, error: error.code, completed_at: Time.current)
    log(request, started, error.code)
  end

  private

  # FT-001 RB-01: no user text in logs.
  def log(request, started, error = nil)
    Rails.logger.info(
      "plan_request id=#{request.id} model=#{request.model} status=#{request.status} " \
      "duration=#{(Time.current - started).round(2)}s#{" error=#{error}" if error}"
    )
  end
end
