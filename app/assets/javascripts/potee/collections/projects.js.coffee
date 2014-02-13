class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'

  initialize: ->
    @on 'remove', (project) ->
      project.destroy()

    @comparator = (project) ->
      project.get("position")

  # Ищем следующий свободный цвет
  getNextColorIndex: ->
    return 0 if @length == 0
    max = Potee.Models.Project.prototype.MAX_COLOR_INDEX

    if @length>=max
      return (@last().get('color_index')+1) % max
    else
      i=0
      while (i<=max)
        return i unless @findWhere color_index: i
        i++
      return 0

  getByProjectId: (project_id) ->
    # TODO cache
    @findWhere project_id: project_id


  # TODO cache
  firstDate: ->
    @min( (p) -> p.started_at )?.started_at || moment().startOf("day").toDate()

  # TODO cache
  lastDate: ->
    @max( (p) -> p.finish_at )?.finish_at || moment().add("months", 1).endOf("month").toDate()

    #if @length == 0
      #min = moment().startOf("day").toDate()
      #max = moment().add("months", 1).endOf("month").toDate()
    #else
      #min = @first().started_at
      #max = @first().finish_at

    #@each (project)=>
      #if project.started_at < min
        #min = project.started_at

      #if project.finish_at > max
        #max = project.finish_at


