class SharedProject 
  def initialize project, share_key
    @project = project
    @share_key = share_key
  end

  def to_json
    data = @project.as_json.merge share_key: @share_key
    data.to_json
  end
end
