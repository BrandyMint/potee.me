Potee.Views.Titles ||= {}

class Potee.Views.Titles.EditView extends Backbone.View
  template: JST["backbone/templates/titles/edit"]
  tagName: "div"
  className: 'project-title'

  initialize: ->
    _.bindAll(this, 'on_keypress');
    $(document).bind('keydown', this.on_keypress);

  on_keypress: (e) ->
    e ||= window.event
    if e.keyCode == 27
      @cancel()

  events :
    "submit #edit-project" : "update"
    'click .cancel' : 'cancel'

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (project) =>
        @model = project
        @model.view.setTitleView 'show'
        # window.location.hash = "/#{@model.id}"
    )

  keypress: (event)->
    alert(event)

  cancel: ->
    @model.view.setTitleView 'show'

  render: ->
    $(@el).html(@template(@options.project_view.model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
