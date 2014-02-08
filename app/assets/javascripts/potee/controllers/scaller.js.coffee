class Potee.Controllers.Scaller extends Marionette.Controller
  MAX_PIXELS_PER_DAY: 200
  MIN_PIXELS_PER_DAY: 4

  DEFAULT_WEEK_PIXELS_PER_DAY:  150

  START_MONTH_PIXELS_PER_DAY:   30  # start month if less
  DEFAULT_MONTH_PIXELS_PER_DAY: 20

  START_YEAR_PIXELS_PER_DAY:    15
  DEFAULT_YEAR_PIXELS_PER_DAY:  10

  initialize: (options) ->
    { @dashboard } = options

    Mousetrap.bind '+', @incPixelsPerDay
    Mousetrap.bind '-', @decPixelsPerDay
    Mousetrap.bind '0', @toggleScale

  toggleScale: =>
    if @getScale() == @DEFAULT_YEAR_PIXELS_PER_DAY
      @setScale  @DEFAULT_YEAR_PIXELS_PER_DAY
    else
      @setScale @DEFAULT_WEEK_PIXELS_PER_DAY

  getScale: =>
    @dashboard.get 'pixels_per_day'

  setScale: (pixels) =>
    @dashboard.set 'pixels_per_day', parseInt(pixels)

  #
  # PixelsPerDay
  # 

  # Вынести в ScaleController
  # Изменение масштаба крутилкой мышки
  pinch: (scale) ->
    @setScale @getScale() * scale

  incPixelsPerDay: =>
    diff = 5
    diff = 3 if @getScale() < 100
    diff = 1 if @getScale() < 50
    new_value = @_normalizePixelsPerDay @getScale()+diff
    @setScale new_value

  decPixelsPerDay: =>
    diff = 5
    diff = 3 if @getScale() < 100
    diff = 1 if @getScale() < 50
    new_value = @_normalizePixelsPerDay @getScale()-diff
    @setScale new_value

  _normalizePixelsPerDay: (pixels_per_day) ->
    Math.max Math.min(pixels_per_day, @MAX_PIXELS_PER_DAY), @MIN_PIXELS_PER_DAY
