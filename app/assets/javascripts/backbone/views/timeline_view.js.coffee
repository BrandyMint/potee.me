class Potee.Views.TimelineView extends Backbone.View
  id: 'timeline'
  tagName: 'div'

  scale: 'days'

  initialize: ->
    @dashboard = @options.dashboard
    @view = @options.view

  changeScale: (scale) ->
    switch scale
      when 'days'   then @scaleClass = Potee.Views.Timelines.DaysView
      when 'weeks'  then @scaleClass = Potee.Views.Timelines.WeeksView
      when 'months' then @scaleClass = Potee.Views.Timelines.MonthsView

    @currentView = new @scaleClass
      date_start: moment(@dashboard.min_with_span())
      date_finish: moment(@dashboard.max_with_span())
      column_width: @dashboard.pixels_per_day_excluding_border
      dashboard: @dashboard
      time_line: this

    @$el.html @currentView.render().el

  render: ->
    # TODO [AK 13/10/12] render view depends on user settings
    @changeScale window.dashboard.get('scale')

    return this

