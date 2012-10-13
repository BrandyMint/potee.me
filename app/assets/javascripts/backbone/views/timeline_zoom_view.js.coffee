class Potee.Views.TimelineZoomView extends Backbone.View
  template: JST["backbone/templates/timeline_zoom"]
  id: 'timeline-zoom'
  tagName: 'div'

  initialize: ->
    @dashboard_view = @options.dashboard_view

  events:
    "click .zoom-control .btn" : "zoom"

  zoom: (event) ->
    level = event.target.getAttribute('data-zoom-level')
    dashboard = @dashboard_view.dashboard
    switch level
      when 'days' then view = new Potee.Views.Timelines.DaysView(moment(dashboard.min), moment(dashboard.max))
      when 'weeks' then view = new Potee.Views.Timelines.WeeksView(moment(dashboard.min), moment(dashboard.max))
      when 'months' then view = new Potee.Views.Timelines.MonthsView(moment(dashboard.min), moment(dashboard.max))
    @dashboard_view.timeline_view = new Potee.Views.TimelineView
      dashboard: dashboard
      view: view

    # FIXME [AK] maybe there is another way
    $('#dashboard').html('')
    @dashboard_view.render()

  render: ->
    $(@el).html(@template)

    return this

