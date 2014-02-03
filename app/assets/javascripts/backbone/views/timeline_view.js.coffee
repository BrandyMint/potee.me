class Potee.Views.TimelineView extends Backbone.View
  initialize: (options)->
    @dashboard = options.dashboard
    @$viewport = options.$viewport

    @listenTo @dashboard, 'change:pixels_per_day', @resetScale

  resetScale: =>
    # Если title не изменился, то и класс менять не надо
    if @last_scale == @dashboard.getTitle() && @currentView?
      @currentView.render()
    else
      scale = @dashboard.getTitle()

      switch scale
        when 'week'   then @scaleClass = Potee.Views.Timelines.DaysView
        when 'month'  then @scaleClass = Potee.Views.Timelines.WeeksView
        when 'year'   then @scaleClass = Potee.Views.Timelines.MonthsView
        else console.log('unknown scale ' + scale)

      @currentView?.close()

      @currentView = new @scaleClass
        dashboard_info: window.dashboard_info
        projects_info:  window.projects_info
        dashboard: @dashboard
        time_line: @

      @$el.html @currentView.render().el

    Backbone.pEvent.trigger 'timeline:stretched'

    @last_scale = scale

  render: ->
    @resetScale()

    @

  #
  # Набор хелперов
  #

  columnWidth: ->
    @currentView.columnWidth()

  startDate: ->
    @currentView.startDate()

  finishDate: ->
    @currentView.finishDate()

  #getDateOfDay: (day) ->
    #@currentView.getDateOfDay day

  offsetInPixels: (day) ->
    @currentView.offsetInPixels day

  width: ->
    @$el.width()

  #
  #

  isDateOnDashboard: (date) ->
    left = @$viewport.scrollLeft() 
    right = left + @$viewport.width()
    offset =  @offsetInPixels date
    left < offset < right

  todayIsPassed: ->
    left = @$viewport.scrollLeft()
    # right = left + @view.viewportWidth()
    offset =  @offsetInPixels @today
    offset < left

  # Возвращает дату для указанной позиции в пикселе
  #
  # @param [Integer] x X-координата
  momentAt: (x) ->
    pd = @dashboard.get 'pixels_per_day'
    days = Math.floor x / pd
    daysWidth = days * pd

    hours = Math.floor((x - daysWidth) / (pd / 24))
    hoursWidth = Math.round(hours * (pd / 24))

    minutes = Math.round((x - daysWidth - hoursWidth) / (pd / (24 * 60)))

    return moment(@startDate()).clone().
      add("days", days).
      hours(hours).
      minutes(minutes)

  momentOfTheMiddle: ->
    @momentAt @$viewport.scrollLeft() + (@$viewport.width() / 2)

  # Координаты дня для сердины экрана
  middleOffsetOf: (day) ->
     x = Math.round @offsetInPixels( day ) - (@$viewport.width() / 2)
     return 0 if x < 0
     return x
