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

  START_MONTH_PIXELS_PER_DAY:   30  # start month if less
  DEFAULT_MONTH_PIXELS_PER_DAY: 20

  START_YEAR_PIXELS_PER_DAY:    15
  DEFAULT_YEAR_PIXELS_PER_DAY:  10

  initialize: ->
    @projects = window.projects
    #@findStartEndDate()

    @on 'change:pixels_per_day', @setTitleFromPixels

    # @on 'change:current_date', => console.log "set current_date = #{@get('current_date')?.toString()}"

    @today = moment()

    @setToday()

  setTitleFromPixels: (a,b) ->
    console.log "scale: #{@getTitle()}, pixels: #{@get('pixels_per_day')}"

  getCurrentMoment: ->
    moment @get('current_date')

  getCurrentDate: ->
    @getCurrentMoment().toDate()

  setCurrentDate: (date) ->
    @set 'current_date', date?.toISOString()

  setToday: ->
    @setCurrentDate undefined

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

  setScale: (period) ->
    return if period == @getTitle()
    switch period
      when 'week' then pixels = @DEFAULT_WEEK_PIXELS_PER_DAY
      when 'month' then pixels = @DEFAULT_MONTH_PIXELS_PER_DAY
      when 'year' then pixels = @DEFAULT_YEAR_PIXELS_PER_DAY
      else throw "Unknown scale title #{period}"

    @set 'pixels_per_day', pixels

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

  # Вынести в ScaleController
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
