class Potee.Views.Titles.NewView extends Potee.Views.Titles.EditView
  template: JST["backbone/templates/titles/new"]
  events :
    "submit #new-project"  : "create"
    'click #cancel'        : 'cancelEvent'

  create: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (project) =>
        project.view = @model.view
        @model = project
        @model.view.setTitleView 'show'
        window.location.hash = "/"

      error: (project, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

