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

  destroyEvent: (e) ->
    @model.view.destroy()

  cancelEvent: (e) ->
    window.dashboard.view.cancelCurrentForm()

  cancel: ->
    $(document).unbind 'click'

    if @model.isNew()
      # @model.view.remove()
      @model.view.destroy()
      # @model.remove()
    else
      @model.view.setTitleView 'show'

    $('#project_new').removeClass('active')
    window.location.hash = ''

  render: ->
    $(@el).html(@template(@options.project_view.model.toJSON() ))

    @$el.click (e)->
      event.stopPropagation()

    view = this
    $(document).click ->
      view.cancel()

    #$(@el).bind 'clickoutside', ->
      #alert('asd')
      #view.cancel()

    # if(!$(event.target).is('#foo')))


    @.$("form").backboneLink(@model)
    return this
