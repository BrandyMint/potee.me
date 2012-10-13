class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'

  initialize: (options)->
    @dashboard = options.dashboard
    @setElement($('#dashboard'))
    @render()

  render: ->
    @timeline_view ||= new Potee.Views.TimelineView
      dashboard: this

    @timeline_view.render()
    @$el.append @timeline_view.el

    @projects_view ||= new Potee.Views.Projects.IndexView
      projects: @dashboard.projects

    @$el.append @projects_view.el
    return this

