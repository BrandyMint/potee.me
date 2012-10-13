class Potee.Views.DashboardView extends Backbone.View
  template: JST["backbone/templates/dashboard"]

  id: 'dashboard'
  tagName: 'div'

  initialize: (options)->
    @dashboard = options.dashboard
    @render()

  render: ->

    # TODO Рендерим timeline
    # TODO Рендерим projects
    @projects_view = new Potee.Views.Projects.IndexView(projects: @dashboard.projects)
    $(@el).html(@template(@dashboard.toJSON()))
    return this
