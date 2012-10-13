Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Backbone.View
  template: JST["backbone/templates/projects/project"]

  events:
    "click .destroy" : "destroy"
    "dblclick" : "nextColor"

  tagName: "div"
  className: 'project'

  nextColor: ->
    @model.nextColor()

  bounce: ->
    @$el.effect('bounce', {times: 5}, 200)

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
