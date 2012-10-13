class Potee.Views.DashboardView extends Backbone.View
  template: JST["backbone/templates/dashboard"]

  id: 'dashboard'
  tagName: 'div'

  initialize: ->
    @model = new Potee.Models.Dashboard()
    @render()

  render: ->
    # TODO Рендерим timeline
    # TODO Рендерим projects
    $(@el).html(@template(@model.toJSON() ))
    return this
