Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Backbone.View
  template: JST["backbone/templates/titles/edit"]
  tagName: "div"
  className: 'project-title'

  initialize: ->
    _.bindAll(this, 'on_keypress');
    $(document).bind('keydown', this.on_keypress);
    @collection = window.projects
    @model = @options.model

  on_keypress: (e) ->
    e ||= window.event
    if e.keyCode == 27
      @cancel()

  events :
    "submit #edit-project" : "update"
    "click #submit"        : "update"
    'click #cancel'        : 'cancelEvent'

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

  keypress: (event)->
    alert(event)

  cancelEvent: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @cancel()

  cancel: ->
    $(document).unbind 'click'

    if @model.isNew()
      @model.view.remove()
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
      console.log view
      view.cancel()

    #$(@el).bind 'clickoutside', ->
      #alert('asd')
      #view.cancel()

    # if(!$(event.target).is('#foo')))


    @.$("form").backboneLink(@model)
    return this
