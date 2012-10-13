Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Backbone.View
  template: JST["backbone/templates/projects/project"]
  tagName: "div"
  className: 'project'

  events:
    "click .destroy" : "destroy"
    "dblclick" : "nextColor"

  nextColor: ->
    @model.nextColor()

  bounce: ->
    @$el.effect('bounce', {times: 5}, 200)

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  setFirstDay: (day) ->
    $(@el).css('margin-left', day * window.dashboard.model.pixels_per_day)

  setDuration: (day) ->
    $(@el).css('width', day * window.dashboard.model.pixels_per_day)

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @setFirstDay @model.firstDay
    @setDuration @model.duration
    return this
