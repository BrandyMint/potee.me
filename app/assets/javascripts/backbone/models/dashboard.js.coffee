class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 40
  pixels_per_day_excluding_border: 39
  spanDays: 3

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

    @min = moment(min).toDate()
    @max = moment(max).toDate()

    @days = moment(@max).diff(moment(@min), "days") + @spanDays*2

    return

  # date должен быть объектом Date
  indexOf: (date) ->
    return moment(date).diff(moment(@min), "days") + @spanDays
