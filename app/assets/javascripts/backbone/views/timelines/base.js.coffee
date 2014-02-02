Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.BaseView extends Marionette.ItemView
  borderWidth: 1

  initialize: (options) ->
    @reset options

    @projects = window.projects

  # startDate
  # finishDate
  # getDateOfDay

  #getDateOfDay: (day) ->
     #moment(@projects.firstDate()).clone().add('days', day - @spanDays) #.toDate()

  reset: (options) ->
    console.log "columnWidth: #{@columnWidth()}"

  dateRange: ->
    moment().range @startDate(), @finishDate()

  columnWidth: ->
    window.dashboard.get('pixels_per_day') * @columnRate

  totalWidth: ->
    @columnWidth()*@days().length

  setColumnsWidth: ->
    columnWidth = @columnWidth() - @borderWidth
    @$el.find('table td').width columnWidth
    @$el.find('table').width @totalWidth()

  onRender: =>
    @setColumnsWidth()
    # В Firefox стиль отображения для td должен быть дефолтным в отличии от Chrome
    if $.browser.mozilla
      @$el.find('td').css('display', 'table-cell')

