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
      when 'days'
        view = new Potee.Views.Timelines.DaysView
          date_start: moment(dashboard.min_with_span())
          date_finish: moment(dashboard.max_with_span())
          column_width: dashboard.pixels_per_day_excluding_border
      when 'weeks'
        view = new Potee.Views.Timelines.WeeksView
          date_start: moment(dashboard.min_with_span())
          date_finish: moment(dashboard.max_with_span())
          column_width: dashboard.pixels_per_day_excluding_border
      when 'months'
        view = new Potee.Views.Timelines.MonthsView
          date_start: moment(dashboard.min_with_span())
          date_finish: moment(dashboard.max_with_span())
          column_width: dashboard.pixels_per_day_excluding_border

    @dashboard_view.timeline_view = new Potee.Views.TimelineView
      dashboard: dashboard
      view: view

    # FIXME [AK] maybe there is another way
    $('#dashboard').html('')
    @dashboard_view.render()

  render: ->
    $(@el).html(@template)

    return this

