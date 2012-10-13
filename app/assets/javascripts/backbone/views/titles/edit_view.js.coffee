Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Backbone.View
  template: JST["backbone/templates/titles/edit"]
  tagName: "div"
  className: 'project-title'

  events :
    "submit #edit-project" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (project) =>
        @model = project
        @model.view.setTitleView 'show'
        # window.location.hash = "/#{@model.id}"
    )


  render: ->
    $(@el).html(@template(@options.project_view.model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
