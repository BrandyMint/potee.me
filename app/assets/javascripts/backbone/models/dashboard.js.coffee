class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 40
  pixels_per_day_excluding_border: 39
  spanDays: 3

  defaults:
    scale: 'days'

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

  min_with_span: () ->
    moment(@min).clone().subtract('days', @spanDays).toDate()

  max_with_span: () ->
    # Проект заканчивается к какому-то числу, поэтому сдвигать границу
    # надо надо @spanDays - 1 дней.
    moment(@max).clone().add('days', @spanDays - 1).toDate()

  # Возвращает индекс элемента
  #
  # @param [Date] date дата
  # @param [String] input формат (days - дни, months - месяцы, weeks - недели)
  indexOf: (date, input) ->
    index = moment(date).diff(moment(@min), input)
    if input == "days"
      index = index + @spanDays
    index

  # Возвращает время в зависимости от X
  #
  # @param [Integer] x_coord X-координата
  datetime_by_x_coord: (project, x_coord) ->
    day_index = (x_coord / this.pixels_per_day) - @spanDays
    days = Math.floor(day_index)
    hours = Math.round((day_index - days) * 24)
    moment(project.started_at).clone().add('d', days).add('h', hours).toDate()

  setScale: (scale) ->
    switch scale
      when "days"
        @pixels_per_day = 40
      when "weeks"
        @pixels_per_day = 20
      when "months"
        @pixels_per_day = 10

    @set('scale', scale)
