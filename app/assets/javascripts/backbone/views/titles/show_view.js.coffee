Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Backbone.View
  template: JST["backbone/templates/titles/edit"]
  tagName: "div"
  className: 'project-title'

  render: ->
    $(@el).html(@template(@options.project_view.model.toJSON() ))

    return this
