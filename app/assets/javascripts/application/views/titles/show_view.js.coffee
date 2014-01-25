Potee.Views.Titles ||= {}

class Potee.Views.Titles.ShowView extends Backbone.View
  template: JST["application/templates/titles/show"]
  tagName: "div"
  className: 'project-title'

  initialize: ->
    @sticky_pos = undefined

  render: ->
    $(@el).html(@template(@options.project_view.model.toJSON() ))

    return this
