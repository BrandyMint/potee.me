class Potee.Views.Titles.NewView extends Potee.Views.Titles.EditView
  template: JST["backbone/templates/titles/new"]
  events :
    "submit #new-project"  : "create"
    "click #submit"        : "create"
    'click #cancel'        : 'cancelEvent'
    'mousedown': (e) -> e.stopPropagation()

  create: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (project) =>
        $('#project_new').removeClass('active')

        project.view = @model.view
        @model = project
        @model.view.model = project
        @model.view.setTitleView 'show'
        window.location.hash = '/'

      error: (project, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

