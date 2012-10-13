class Potee.Views.TimelineView extends Backbone.View
  id: 'timeline'
  tagName: 'div'

  initialize: ->
    @dashboard = @options.dashboard
    @view = @options.view

  render: ->
    # TODO [AK 13/10/12] render view depends on user settings
    @view ||= new Potee.Views.Timelines.DaysView
      date_start: moment(@dashboard.min)
      date_finish: moment(@dashboard.max)
      column_width: @dashboard.pixels_per_day - 1 # Толщина бордера

    @$el.html(@view.render().el)

    return this

