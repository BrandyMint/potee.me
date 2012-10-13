class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 40

  initialize: (projects) ->
    @projects = new Potee.Collections.ProjectsCollection()
    @projects.reset(projects)

    @findStartEndDate()
    return

  # По списку проектов находит крайние левую и правые даты
  findStartEndDate: ->
    @min = @projects.first().started_at
    @max = @projects.first().finish_at

    @projects.each((project)=>
        if project.started_at < @min
          @min = project.started_at

        if project.finish_at > @max
          @max = project.finish_at
    )

    return

  durationInDays: ->
    return moment(@max).diff(moment(@min), "days")

  # date должен быть объектом Date
  indexOf: (date) ->
    return moment(date).diff(moment(@min), "days")
