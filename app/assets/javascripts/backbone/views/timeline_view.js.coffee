class Potee.Views.TimelineView extends Backbone.View
  initialize: (options)->
    @dashboard = options.dashboard

  resetScale: =>
    # Если title не изменился, то и класс менять не надо
    if @last_scale == scale && @currentView?
      @currentView.reset
        date_start: moment @dashboard.min_with_span()
        date_finish: moment @dashboard.max_with_span()
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
        date_start: moment(@dashboard.min_with_span())
        date_finish: moment(@dashboard.max_with_span())
        dashboard: @dashboard
        time_line: @

      @$el.html @currentView.render().el

    @last_scale = scale


  render: ->
    @resetScale()

    @
