Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Backbone.View
  template: JST["backbone/templates/titles/edit"]
  tagName: "div"
  className: 'project-title'

  initialize: ->
    @collection = window.projects
    @model = @options.model

  events :
    "submit #edit-project" : "update"
    "click #submit"        : "update"
    'click #cancel'        : 'cancelEvent'
    'click #destroy'       : 'destroyEvent'
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

  render: ->

  destroyEvent: (e) ->
    if confirm("Sure to delete?")
      @model.view.destroy()

  cancelEvent: (e) ->
    window.dashboard.view.cancelCurrentForm()

  cancel: ->
    if @model.isNew()
      @model.view.destroy()
    else
      @model.view.setTitleView 'show'

    $('#project_new').removeClass('active')


  render: ->
    $(@el).html(@template(@options.project_view.model.toJSON() ))

    @.$("form").backboneLink(@model)
    return this
