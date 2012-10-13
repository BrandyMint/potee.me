Potee.Views.Projects ||= {}

class Potee.Views.Projects.EditView extends Backbone.View
  template : JST["backbone/templates/projects/edit"]

  events :
    "submit #edit-project" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (project) =>
        @model = project
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
