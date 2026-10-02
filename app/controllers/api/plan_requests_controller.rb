module Api
  # "Plan from text" (FT-001): POST a plan in plain text, poll until the model's
  # draft is ready, then apply the chosen projects or discard the draft.
  class PlanRequestsController < BaseController
    before_action :require_feature
    before_action :require_account
    before_action :find_request, except: :create

    def create
      requests = current_user.plan_requests
      return limit_error("in_progress") if requests.pending.where(created_at: PlanRequest::STALE_AFTER.ago..).exists?
      return limit_error("daily_limit") if requests.today.count >= PlanRequest::DAILY_LIMIT

      plan = requests.create!(prompt: params.require(:prompt).to_s.strip, timezone: params[:timezone].presence || "Europe/Moscow",
                              model: PlanGenerator.model)
      GeneratePlanJob.perform_later(plan.id)
      render json: plan.as_status_json, status: :accepted
    end

    def show
      @plan.fail_if_stale!
      render json: @plan.as_status_json
    end

    def apply
      return render(json: { error: "not_ready" }, status: :conflict) unless @plan.ready?

      keys = Array(params[:project_keys]).map(&:to_s)
      chosen = @plan.draft["projects"].select { keys.include?(_1["key"]) }
      return render(json: { error: "nothing_selected" }, status: :unprocessable_content) if chosen.empty?

      writer = BoardWriter.new(current_user)
      connections = PlanRequest.transaction do
        created = chosen.map { add(writer, _1) }
        @plan.update!(status: :applied, applied_at: Time.current)
        created
      end
      render json: { projects: connections.map { card_json(_1.reload) } }, status: :created
    end

    def discard
      @plan.update!(status: :discarded) if @plan.ready? || @plan.failed?
      head :no_content
    end

    private

    def add(writer, project)
      events = project["events"].map do |event|
        day = Date.iso8601(event["date"])
        hours, minutes = event["time"].split(":").map(&:to_i)
        { title: event["title"], at: @plan.zone.local(day.year, day.month, day.day, hours, minutes) }
      end
      writer.add_project(title: project["title"], started_on: Date.iso8601(project["start_date"]),
                         finished_on: Date.iso8601(project["end_date"]), events:)
    end

    def require_feature
      head :not_found unless PlanRequest.enabled?
    end

    def require_account
      render json: { error: "sign_up_required" }, status: :forbidden if current_user.anonymous?
    end

    def find_request
      @plan = current_user.plan_requests.find(params[:id])
    end

    def limit_error(code)
      render json: { error: code }, status: :too_many_requests
    end
  end
end
