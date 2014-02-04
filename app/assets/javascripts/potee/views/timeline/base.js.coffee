Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.BaseView extends Marionette.ItemView
  borderWidth: 1

  initialize: (options) ->
    @projects = window.projects

  _extraColumns: ->
    offset = @offsetInPixels @_finishDate()
    extra_columns_pixels = window.viewport.width() - offset

    minimal = @columnWidth() * 1.5
    extra_columns_pixels = minimal if extra_columns_pixels<minimal
    extra_column = Math.round extra_columns_pixels/@columnWidth()
    extra_column = 1 if extra_column < 1

    extra_column

  # startDate
  # finishDate
  # getDateOfDay

  #getDateOfDay: (day) ->
     #moment(@projects.firstDate()).clone().add('days', day - @spanDays) #.toDate()
  totalWidth: ->
    days_width = (@finishDate().diff( @startDate(), 'days' ) + 1) * window.dashboard.get('pixels_per_day')
    width = @columnWidth() * @columns_count()

    console.log "Ширина в днях #{days_width} не равна ширине в пикселях #{width}" unless days_width == width

    return width

  columnsOnTheScreenCount: ->
    w = window.dashboard_view.width() / @columnWidth()

    #console.log 'columnsOnTheScreenCount', w

  # Для месяцев придется переопределить
  offsetInPixels: (day) ->
    minutes = moment(day).diff @startDate(), 'minutes'
    (window.dashboard.get('pixels_per_day') * minutes) / (24*60)

  dateRange: ->
    moment().range @startDate(), @finishDate()

  columnWidth: ->
    window.dashboard.get('pixels_per_day') * @columnRate

  _setColumnsWidth: ->
    columnWidth = @columnWidth() - @borderWidth
    @$el.find('table td').width columnWidth

    @$el.find('table').width @totalWidth()

    PoteeApp.seb.fire 'timeline:reset_width', @totalWidth()

  onRender: =>
    @_setColumnsWidth()
    # В Firefox стиль отображения для td должен быть дефолтным в отличии от Chrome
    if $.browser.mozilla
      @$el.find('td').css('display', 'table-cell')

