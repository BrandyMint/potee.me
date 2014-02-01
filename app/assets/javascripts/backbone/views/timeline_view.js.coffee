class Potee.Views.TimelineView extends Backbone.View
  initialize: (options)->
    @dashboard = options.dashboard

  startDate: ->
    @currentView.startDate()

  finishDate: ->
    @currentView.finishDate()

  getDateOfDay: (day) ->
    @currentView.getDateOfDay day

  offsetInPixels: (day) ->
    @currentView.offsetInPixels day

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

  width: ->
    @$el.width()

  resetScale: =>
    # Если title не изменился, то и класс менять не надо
    if @last_scale == scale && @currentView?
      @currentView.reset()
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
