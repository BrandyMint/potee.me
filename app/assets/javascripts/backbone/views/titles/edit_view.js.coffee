Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Marionette.ItemView
  template: JST["backbone/templates/titles/edit"]
  className: "project-title"

  initialize: (@options) ->
    @collection = window.projects
    @model = @options.model

  events:
    "submit #edit-project" : "update"
    "click #submit"        : "update"
    'click #cancel'        : 'cancelEvent'
    'click #destroy'       : 'destroyProject'
    'mousedown': (e) -> e.stopPropagation()

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (project) =>
        @model = project
        window.dashboard.view.cancelCurrentForm()
        @model.view.setTitleView 'show'
    )

  destroyProject: (e) ->
    e.preventDefault()

    if confirm("Sure to delete?")
      @model.destroy()

  cancelEvent: (e) ->
    window.dashboard.view.cancelCurrentForm()

  cancel: ->
    if @model.isNew()
      @model.destroy()
    else
      @model.view.setTitleView 'show'

    $('#project_new').removeClass('active')

  onRender: ->
    @$("form").backboneLink(@model)
    @
