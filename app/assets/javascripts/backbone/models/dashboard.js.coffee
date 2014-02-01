class Potee.Models.Dashboard extends Backbone.Model
  url: '/'

  methodToURL:
    'read': '/dashboard/read',
    'update': '/dashboard/update'

  sync: (method, model, options) ->
    options = options || {}
    options.url = model.methodToURL[method.toLowerCase()]
    Backbone.sync(method, model, options)

  MAX_PIXELS_PER_DAY: 200
  MIN_PIXELS_PER_DAY: 4

  DEFAULT_WEEK_PIXELS_PER_DAY:  150

  START_MONTH_PIXELS_PER_DAY:   50
  DEFAULT_MONTH_PIXELS_PER_DAY: 35

  START_YEAR_PIXELS_PER_DAY:    30
  DEFAULT_YEAR_PIXELS_PER_DAY:  10

  initialize: ->
    @projects = window.projects
    @viewport = window.viewport
    #@findStartEndDate()

    @on 'change:pixels_per_day', @setTitleFromPixels

    # TODO Сохранять с задержкой в 3 секунды
    #@on 'change', => @save()

    @today = moment()

    @setToday()

  setTitleFromPixels: (a,b) ->
    console.log "scale: #{@getTitle()}, pixels: #{@get('pixels_per_day')}"

  setToday: ->
    @set 'current_date', undefined

  getCurrentMoment: ->
    moment @get('current_date')

  getCurrentDate: ->
    @getCurrentMoment().toDate()

  setCurrentDate: (date) ->
    console.log "set current_date = #{date.toString()}"
    @set 'current_date', date.toString()

  min_with_span: () ->
    debugger
    throw 'err'
    switch @getTitle()
      when "week"
       return moment(@min).clone().subtract('days', @spanDays).toDate()
      when "month"
        return moment(@min).clone().day(0).toDate()
      when "year"
        return moment(@min).clone().startOf("month").toDate()

  max_with_span: () ->
    debugger
    throw 'err'
    switch @getTitle()
      when "week"
        return moment(@max).clone().add('days', @spanDays).toDate()
      when "month"
        return moment(@max).clone().day(6).toDate()
      when "year"
        return moment(@max).clone().endOf("month")

  # Координаты дня для сердины экрана
  middleOffsetOf: (day) ->
     x = @_middleOffsetOf(day)
     return 0 if x < 0
     return x

  _middleOffsetOf: (day) ->
     @offsetOf( day ) - (@viewport.width() / 2)

  offsetOf: (day) ->
    window.timeline_view.offsetInPixels day

  dayOfOffset: (offset) ->
    Math.round( offset / @get('pixels_per_day') )

  momentOfMiddleOffset: (offset) ->
    window.timeline_view.momentAt offset + (@viewport.width() / 2)

  # Возвращает индекс элемента
  #
  # @param [Date] date дата
  # FIX убрать days/months/weeks. indexOf всегда должен вовращать номер дня
  # @param [String] input формат (days - дни, months - месяцы, weeks - недели)
  #indexOf: (date, input='days') ->
    #index = moment(date).diff(moment(@min), input)
    #if input == "days"
      #index = index + @spanDays
    #index

  dateIsOnDashboard: (date) ->
    left = @view.viewport.scrollLeft() 
    right = left + @viewport.width()
    offset =  @offsetOf(date)
    left < offset < right

  todayIsPassed: ->
    left = @viewport.scrollLeft()
    # right = left + @view.viewportWidth()
    offset =  @offsetOf(@today)
    offset < left

  #width: ->
    #return @days * @get('pixels_per_day')

  #setWidth: (width) ->
    #duration = Math.round(width / @get('pixels_per_day'))
    #@max = moment(@min_with_span()).clone().add("days", duration)
    #@setDuration()

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
