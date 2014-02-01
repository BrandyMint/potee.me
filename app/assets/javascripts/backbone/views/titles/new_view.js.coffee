class Potee.Views.Titles.NewView extends Potee.Views.Titles.EditView
  template: "templates/titles/new"
  events :
    "submit #new-project"  : "create"
    "click #submit"        : "create"
    'click #cancel'        : 'cancel'
    'mousedown': (e) -> e.stopPropagation()

  create: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (project) =>
        $('#project_new').removeClass('active')

        project_view = @model.view
        project_view.resetModel project
        project_view.setTitleView 'show'
        window.location.hash = '/'

      error: (project, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )
