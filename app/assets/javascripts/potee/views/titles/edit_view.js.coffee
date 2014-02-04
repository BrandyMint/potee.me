Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Marionette.ItemView
  FOREGROUNG_Z_INDEX: 300
  template: "templates/titles/edit"

  initialize: (@options) ->
    @collection = window.projects
    @model = @options.model

  events:
    "submit #edit-project" : "update"
    "click #submit"        : "update"
    'click #cancel'        : 'cancel'
    'click #destroy'       : 'destroyProject'
    'mousedown': (e) -> e.stopPropagation()

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (project) =>
        @model = project
        #window.dashboard.view.cancelCurrentForm()
        @model.view.setTitleView 'show'
    )

  destroyProject: (e) ->
    e.preventDefault()

    if confirm("Sure to delete?")
      @model.destroy()

  cancel: =>
    @close()

  onClose: ->
    if @model.isNew()
      @model.destroy()
    else
      @model.view.setTitleView 'show'

    $('#project_new').removeClass 'active'

  onRender: ->
    @$("form").backboneLink @model
    @$('input#title').focus()

    @$el.css 'z-index', @FOREGROUNG_Z_INDEX
    @
