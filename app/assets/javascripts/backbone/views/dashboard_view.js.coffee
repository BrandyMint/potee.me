class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'

  initialize: (options)->
    @dashboard = options.dashboard
    @setElement($('#dashboard'))
    @resetWidth()
    @render()

  resetWidth: ->
    @$el.css('width', @dashboard.days * @dashboard.pixels_per_day)

  render: ->
    @timeline_zoom_view = new Potee.Views.TimelineZoomView
      dashboard_view: this
    @timeline_zoom_view.render()
    $('#timeline-zoom-container').html @timeline_zoom_view.el

    @timeline_view ||= new Potee.Views.TimelineView
      dashboard: @dashboard
    @timeline_view.render()
    @$el.append @timeline_view.el

    @projects_view ||= new Potee.Views.Projects.IndexView
      projects: @dashboard.projects

    @$el.append @projects_view.el
    return this

