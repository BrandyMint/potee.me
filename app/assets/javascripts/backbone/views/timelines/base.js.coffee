Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.BaseView extends Marionette.ItemView

  initialize: (options) ->
    @reset(options)

  reset: (options) ->
    @start = moment options.date_start, "YYYY-MM-DD"
    @end   = moment options.date_finish, "YYYY-MM-DD"
    @range = moment().range(@start, @end)

    console.log "columnWidth: #{@columnWidth()}"

  columnWidth: ->
    @options.dashboard.get('pixels_per_day') * @columnRate

  setColumnsWidth: ->
    columnWidth = @columnWidth() - 1 # 1px на правую границу
    @$el.find('table td').attr('width', columnWidth + "px")

  onRender: =>
    @setColumnsWidth()
    # В Firefox стиль отображения для td должен быть дефолтным в отличии от Chrome
    if $.browser.mozilla
      @$el.find('td').css('display', 'table-cell')

    Backbone.pEvent.trigger 'timeline:render'
