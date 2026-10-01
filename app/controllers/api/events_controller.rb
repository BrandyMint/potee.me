module Api
  class EventsController < BaseController
    def create
      connection = current_user.project_connections.find(params[:project_id])
      connection.project.edited!
      event = connection.project.events.create!(event_params)
      render json: event.as_card_json, status: :created
    end

    def update
      event.project.edited!
      event.update!(event_params)
      render json: event.as_card_json
    end

    def destroy
      event.project.edited!
      event.destroy!
      head :no_content
    end

    private

    def event_params
      params.expect(event: %i[title at])
    end

    def event
      @event ||= Event.where(project_id: current_user.project_connections.select(:project_id)).find(params[:id])
    end
  end
end
