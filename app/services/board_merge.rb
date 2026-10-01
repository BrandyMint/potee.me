# Logging in from an anonymous board moves what the visitor made there into
# the account. Untouched sample projects are dropped instead of duplicated.
class BoardMerge
  def self.call(from:, into:)
    new(from, into).call
  end

  def initialize(from, into)
    @from = from
    @into = into
  end

  def call
    return if @from.nil? || @from == @into || !@from.anonymous?

    User.transaction do
      position = @into.project_connections.maximum(:position).to_i
      @from.project_connections.includes(:project).order(:position).each do |connection|
        project = connection.project
        next if project.demo? && project.owner_id == @from.id
        next if @into.project_connections.exists?(project_id: project.id)

        connection.update!(user: @into, position: position += 1)
        project.update!(owner: @into) if project.owner_id == @from.id
      end
      @from.reload.destroy!
    end
  end
end
