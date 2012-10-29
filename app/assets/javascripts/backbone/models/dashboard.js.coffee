class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 150
  week_pixels_per_day: 150
  spanDays: 3

  defaults:
    scale: 'week'

  initialize: (attributes, options, @projects) ->
    @findStartEndDate()
    @on 'change:scale', @changeScale
    @today = moment()

    @setToday()
    return

  setToday: ->
    @currentDate = undefined

  getCurrentDate: ->
    @currentDate || moment().startOf("day").add("hours", 12)

  setCurrentDate: (date) ->
    if date == @today
      @currentDate = undefined
    else
      @currentDate = date
    @view.resetTodayLink @currentDate

  changeScale: =>
    switch @get('scale')
      when "week"
        @pixels_per_day = @week_pixels_per_day
      when "month"
        @pixels_per_day = 34
      when "year"
        @pixels_per_day = 4

    @setDuration(@min, @max)
    if @view
      @view.setScale @get('scale')

  # По списку проектов находит крайние левую и правые даты
  findStartEndDate: ->
    if @projects.length == 0
      min = moment().startOf("day").toDate()
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

  getDateOfDay: (day) ->
     return moment(@min).clone().add('days', day - @spanDays) #.toDate()

  # Координаты дня для сердины экрана
  middleOffsetOf: (day) ->
     x = @_middleOffsetOf(day)
     return 0 if x < 0
     return x

  _middleOffsetOf: (day) ->
     @offsetOf( day ) - (@view.viewportWidth() / 2)

  offsetOf: (day) ->
    # Это Дата?
    if _.isObject(day)
      minutes = moment(day).diff(moment(@min_with_span()), 'minutes') 
      (@pixels_per_day * minutes) / (24*60)
    else
      day * @pixels_per_day

  dayOfOffset: (offset) ->
    Math.round( offset / @pixels_per_day )

  dayOfMiddleOffset: (offset) ->
    @dayOfOffset( offset + (@view.viewportWidth() / 2) - @pixels_per_day / 2)

  dateOfMiddleOffset: (offset) ->
    @datetimeAt offset + (@view.viewportWidth() / 2)

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

  dateIsOnDashboard: (date) ->
    left = @view.viewport.scrollLeft() 
    right = left + @view.viewportWidth()
    offset =  @offsetOf(date)
    left < offset < right

  todayIsPassed: ->
    left = @view.viewport.scrollLeft()
    # right = left + @view.viewportWidth()
    offset =  @offsetOf(@today)
    offset < left

  # Возвращает время в зависимости от X
  #
  # @param [Integer] x X-координата
  datetimeAt: (x) ->
    days = Math.floor(x / @pixels_per_day)
    daysWidth = days * @pixels_per_day

    hours = Math.floor((x - daysWidth) / (@pixels_per_day / 24))
    hoursWidth = Math.round(hours * (@pixels_per_day / 24))

    minutes = Math.round((x - daysWidth - hoursWidth) / (@pixels_per_day / (24 * 60)))
    return moment(@min_with_span()).clone().add("days", days).hours(hours).minutes(minutes)

  # Возвращает количество дней перед днем старта 1 проекта
  days_before_min: ->
    moment(@min).diff(@min_with_span(), 'days')

  width: ->
    return @days * @pixels_per_day

  setWidth: (width) ->
    duration = Math.round(width / @pixels_per_day)
    @max = moment(@min_with_span()).clone().add("days", duration)
    @setDuration()
