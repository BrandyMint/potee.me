module Api
  # Projects are addressed by the current user's connection id: that is what a
  # board row is (shared data lives in Project, per-user data in the connection).
  class ProjectsController < BaseController
    PROJECT_FIELDS = %i[title started_on finished_on].freeze
    CONNECTION_FIELDS = %i[color_index position].freeze

    def create
      attributes = params.expect(project: PROJECT_FIELDS + CONNECTION_FIELDS)
      connection = ProjectConnection.transaction do
        project = current_user.owned_projects.create!(attributes.slice(*PROJECT_FIELDS))
        project.project_connections.create!(
          user: current_user,
          color_index: attributes.fetch(:color_index, current_user.next_color_index),
          position: attributes.fetch(:position, 0)
        )
      end
      render json: card_json(connection), status: :created
    end

    def update
      attributes = params.expect(project: PROJECT_FIELDS + CONNECTION_FIELDS)
      ProjectConnection.transaction do
        connection.project.update!(attributes.slice(*PROJECT_FIELDS)) if attributes.slice(*PROJECT_FIELDS).present?
        connection.update!(attributes.slice(*CONNECTION_FIELDS)) if attributes.slice(*CONNECTION_FIELDS).present?
      end
      render json: card_json(connection.reload)
    end

    def destroy
      connection.destroy!
      head :no_content
    end

    # Saves the order of the user's board rows: ids are connection ids, top first.
    def reorder
      ids = Array(params.require(:ids)).map(&:to_i)
      connections = current_user.project_connections.where(id: ids).index_by(&:id)
      ProjectConnection.transaction do
        ids.each_with_index { |id, position| connections[id]&.update_column(:position, position) }
      end
      head :no_content
    end

    private

    def connection
      @connection ||= current_user.project_connections.find(params[:id])
    end
  end
end
