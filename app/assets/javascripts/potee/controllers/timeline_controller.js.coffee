class Potee.Views.TimelineView extends Backbone.View
  initialize: (options)->
    { @dashboard, @$viewport } = options

    # Причем именно за window, а не за #viewport
    $(window).resize @resizeCallback

    @listenTo @dashboard, 'change:pixels_per_day', @render

  render: =>
    # Если title не изменился, то и класс менять не надо
    scale = @getScaleMode()
    if @last_scale == scale && @currentView?
      @currentView.render()
    else

      switch scale
        when 'days'   then @scaleClass = Potee.Views.Timelines.DaysView
        when 'weeks'  then @scaleClass = Potee.Views.Timelines.WeeksView
        when 'months'   then @scaleClass = Potee.Views.Timelines.MonthsView
        else console.log('unknown scale ' + scale)

      @currentView?.close()

      @currentView = new @scaleClass
        dashboard_info: window.dashboard_info
        projects_info:  window.projects_info
        dashboard: @dashboard
        time_line: @

      @$el.html @currentView.render().el

    @last_scale = scale
    @resetHeight()

    PoteeApp.seb.fire 'timeline:scale_mode', scale

    @

  resetHeight: =>
    @$timeline_td = $('#timeline table tbody td')
    console.log 'resetHeight', @$viewport.height()
    @$timeline_td.height @$viewport.height()

  resizeCallback: =>
    @resetHeight()

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

  getScaleMode: ->
    p = @dashboard.get 'pixels_per_day'
    if p <= Potee.Controllers.Scaller.prototype.START_YEAR_PIXELS_PER_DAY
      return 'months'
    else if p <= Potee.Controllers.Scaller.prototype.START_MONTH_PIXELS_PER_DAY
      return 'weeks'
    else
      return 'days'
