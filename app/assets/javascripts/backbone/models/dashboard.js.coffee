class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 40

  initialize: (@projects) ->
    @findStartEndDate()
    return

  # По списку проектов находит крайние левую и правые даты
  findStartEndDate: ->
    min = @projects.first().started_at
    max = @projects.first().finish_at

    @projects.each((project)=>
        if project.started_at < min
          min = project.started_at

        if project.finish_at > max
          max = project.finish_at
    )

    @min = moment(min).subtract("days", 3).toDate()
    @max = moment(max).add("days", 3).toDate()

    @days = moment(@max).diff(moment(@min), "days") + 3 # FIX

    return

  # date должен быть объектом Date
  indexOf: (date) ->
    return moment(date).diff(moment(@min), "days")
