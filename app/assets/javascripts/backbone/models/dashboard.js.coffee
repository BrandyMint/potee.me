class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 80
  spanDays: 3

  defaults:
    scale: 'days'

  initialize: (@projects) ->
    @findStartEndDate()
    @on 'change:scale', @changeScale
    return

  changeScale: ->
    switch @get('scale')
      when "days"
        @pixels_per_day = 80
      when "weeks"
        @pixels_per_day = 20
      when "months"
        @pixels_per_day = 10

    @setDuration(@min, @max)
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
      when "days"
       return moment(@min).clone().subtract('days', @spanDays).toDate()
      when "weeks"
        return moment(@min).clone().day(0).toDate()
      when "months"
        return moment(@min).clone().startOf("month").toDate()

  max_with_span: () ->
    switch @get('scale')
      when "days"
        return moment(@max).clone().add('days', @spanDays).toDate()
      when "weeks"
        return moment(@max).clone().day(6).toDate()
      when "months"
        return moment(@max).clone().endOf("month")

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
