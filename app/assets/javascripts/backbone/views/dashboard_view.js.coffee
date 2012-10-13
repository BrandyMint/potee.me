class Potee.Views.DashboardView extends Backbone.View
  template: JST["backbone/templates/dashboard"]

  id: 'dashboard'
  tagName: 'div'

  initialize: (projects)->
    @model = new Potee.Models.Dashboard(projects)
    @render()

  render: ->
    # TODO Рендерим timeline
    # TODO Рендерим projects
    $(@el).html(@template(@model.toJSON() ))
    return this
