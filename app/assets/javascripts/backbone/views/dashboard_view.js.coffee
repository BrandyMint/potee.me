class Potee.Views.DashboardView extends Backbone.View
  id: 'dashboard'
  tagName: 'div'

  initialize: (options)->
    @dashboard = options.dashboard
    @render()

  render: ->

    # TODO Рендерим timeline
    @projects_view = new Potee.Views.Projects.IndexView(projects: @dashboard.projects)
    @$.append @projects_view.el
    return this
