class Potee.Models.Dashboard extends Backbone.Model
  url: '/'

  methodToURL:
    'read': '/dashboard/read',
    'update': '/dashboard/update'

  sync: (method, model, options) ->
    options = options || {}
    options.url = model.methodToURL[method.toLowerCase()]
    Backbone.sync(method, model, options)

  spanDays: 5

  MAX_PIXELS_PER_DAY: 200
  MIN_PIXELS_PER_DAY: 4

  DEFAULT_WEEK_PIXELS_PER_DAY:  150

  START_MONTH_PIXELS_PER_DAY:   50
  DEFAULT_MONTH_PIXELS_PER_DAY: 35

  START_YEAR_PIXELS_PER_DAY:    30
  DEFAULT_YEAR_PIXELS_PER_DAY:  10


  defaults:
    scale: 'week'
    pixels_per_day: 150

  initialize: ->
    @projects = window.projects
    @findStartEndDate()

    @on 'change:pixels_per_day', @setTitleFromPixels

    # TODO Сохранять с задержкой в 3 секунды
    #@on 'change', => @save()

    @today = moment()

    @setToday()

  setTitleFromPixels: (a,b) ->
    console.log "scale: #{@getTitle()}, pixels: #{@get('pixels_per_day')}"

  setToday: ->
    @set 'current_date', undefined

  getCurrentDate: ->
    moment(@get('current_date')).toDate()

  setCurrentDate: (date) ->
    @set 'current_date', date.toString()

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

  min_with_span: () ->
    switch @getTitle()
      when "week"
       return moment(@min).clone().subtract('days', @spanDays).toDate()
      when "month"
        return moment(@min).clone().day(0).toDate()
      when "year"
        return moment(@min).clone().startOf("month").toDate()

  max_with_span: () ->
    switch @getTitle()
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
      (@get('pixels_per_day') * minutes) / (24*60)
    else
      day * @get('pixels_per_day')

  dayOfOffset: (offset) ->
    Math.round( offset / @get('pixels_per_day') )

  dayOfMiddleOffset: (offset) ->
    @dayOfOffset( offset + (@view.viewportWidth() / 2) - @get('pixels_per_day') / 2)

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
    days = Math.floor(x / @get('pixels_per_day'))
    daysWidth = days * @get('pixels_per_day')

    hours = Math.floor((x - daysWidth) / (@get('pixels_per_day') / 24))
    hoursWidth = Math.round(hours * (@get('pixels_per_day') / 24))

    minutes = Math.round((x - daysWidth - hoursWidth) / (@get('pixels_per_day') / (24 * 60)))
    return moment(@min_with_span()).clone().add("days", days).hours(hours).minutes(minutes)

  # Возвращает количество дней перед днем старта 1 проекта
  days_before_min: ->
    moment(@min).diff(@min_with_span(), 'days')

  width: ->
    return @days * @get('pixels_per_day')

  setWidth: (width) ->
    duration = Math.round(width / @get('pixels_per_day'))
    @max = moment(@min_with_span()).clone().add("days", duration)
    @setDuration()

  getTitle: ->
    p = @get 'pixels_per_day'
    if p <= @START_YEAR_PIXELS_PER_DAY
      return 'year'
    else if p <= @START_MONTH_PIXELS_PER_DAY
      return 'month'
    else
      return 'week'

  #
  # PixelsPerDay
  # 
 
  # Изменение масштаба крутилкой мышки
  pinch: (scale) ->
    @set 'pixels_per_day', @model.get('pixels_per_day') * scale

  incPixelsPerDay: ->
    diff = 5 
    diff = 3 if @get('pixels_per_day') < 100
    diff = 1 if @get('pixels_per_day') < 50
    new_value = @normalizePixelsPerDay @get('pixels_per_day')+diff
    @set 'pixels_per_day', new_value

  decPixelsPerDay: ->
    diff = 5 
    diff = 3 if @get('pixels_per_day') < 100
    diff = 1 if @get('pixels_per_day') < 50
    new_value = @normalizePixelsPerDay @get('pixels_per_day')-diff
    @set 'pixels_per_day', new_value

  normalizePixelsPerDay: (pixels_per_day) ->
    Math.max Math.min(pixels_per_day, @MAX_PIXELS_PER_DAY), @MIN_PIXELS_PER_DAY
