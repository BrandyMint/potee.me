class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'

  initialize: (options)->
    @model.view = this
    @setElement($('#dashboard'))
    @resetWidth()
    @render()

  setScale: (scale) ->
    @timeline_view.setScale scale

  resetWidth: ->
    @$el.css('width', @model.days * @model.pixels_per_day)

  render: ->
    @timeline_zoom_view = new Potee.Views.TimelineZoomView

    @timeline_view ||= new Potee.Views.TimelineView
      dashboard: @model
      dashboard_view: this

    @timeline_view.render()
    @$el.append @timeline_view.el

    @projects_view = new Potee.Views.Projects.IndexView
      projects: @model.projects

    @$el.append @projects_view.el
    return this

