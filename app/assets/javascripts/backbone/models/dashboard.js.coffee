class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 150
  spanDays: 3

  defaults:
    scale: 'week'

  initialize: (@projects) ->
    @findStartEndDate()
    @on 'change:scale', @changeScale
    return

  changeScale: =>
    switch @get('scale')
      when "week"
        @pixels_per_day = 150
      when "month"
        @pixels_per_day = 40
      when "year"
        @pixels_per_day = 10

    @setDuration(@min, @max)
    if @view
      @view.setScale @get('scale')

  # По списку проектов находит крайние левую и правые даты
  findStartEndDate: ->
    if @projects.length == 0
      min = moment().toDate()
      max = moment().add("months", 1).endOf("month").toDate()
    else
      min = @projects.first().started_at
      max = @projects.first().finish_at

    @projects.each((project)=>
        if project.started_at < min
          min = project.started_at

        if project.finish_at > max
          max = project.finish_at
    )

    @min = min
    @max = max

    @setDuration()

    return

  setDuration: () ->
    min = @min_with_span()
    max = @max_with_span()

    @days = moment(max).diff(moment(min), "days") + 1
    return

  min_with_span: () ->
    switch @get('scale')
      when "week"
       return moment(@min).clone().subtract('days', @spanDays).toDate()
      when "month"
        return moment(@min).clone().day(0).toDate()
      when "year"
        return moment(@min).clone().startOf("month").toDate()

  max_with_span: () ->
    switch @get('scale')
      when "week"
        return moment(@max).clone().add('days', @spanDays).toDate()
      when "month"
        return moment(@max).clone().day(6).toDate()
      when "year"
        return moment(@max).clone().endOf("month")

  offsetOf: (day) ->
    day * @pixels_per_day

  # Возвращает индекс элемента
  #
  # @param [Date] date дата
  # FIX убрать days/months/weeks. indexOf всегда должен вовращать номер дня
  # @param [String] input формат (days - дни, months - месяцы, weeks - недели)
  indexOf: (date, input='days') ->
    index = moment(date).diff(moment(@min), input)
    if input == "days"
      index = index + @spanDays
    index

  # Возвращает время в зависимости от X
  #
  # @param [Integer] x X-координата
  datetimeAt: (x) ->
    days = Math.floor(x / @pixels_per_day)
    daysWidth = days * @pixels_per_day

    hours = Math.floor((x - daysWidth) / (@pixels_per_day / 24))
    hoursWidth = Math.round(hours * (@pixels_per_day / 24))

    minutes = Math.round((x - daysWidth - hoursWidth) / (@pixels_per_day / (24 * 60)))
    return moment(@min_with_span()).clone().add("days", days).hours(hours).minutes(minutes).toDate()

  # Возвращает количество дней перед днем старта 1 проекта
  days_before_min: ->
    moment(@min).diff(@min_with_span(), 'days')

  width: ->
    return @days * @pixels_per_day

  setWidth: (width) ->
    duration = Math.round(width / @pixels_per_day)
    @max = moment(@min_with_span()).clone().add("days", duration)
    @setDuration()
