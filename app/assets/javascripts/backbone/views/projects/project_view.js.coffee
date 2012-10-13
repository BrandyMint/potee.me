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
    @$el.fadeOut('fast', ->
      @remove
    )

    return false

  setFirstDay: (day) ->
    @$el.css('margin-left', day * window.dashboard.model.pixels_per_day)

  setDuration: (day) ->
    @$el.css('width', day * window.dashboard.model.pixels_per_day)

  setTitleView: (state)->
    switch state
      when 'show' then title_view_class = Potee.Views.Titles.ShowView
      when 'edit' then title_view_class = Potee.Views.Titles.EditView

    options =
      project_view: this

    if @titleEl
      options['el'] = @titleEl

    @titleView = new title_view_class options
    @titleView.render()

    if !@titleEl
      @titleEl = @titleView.el
      @$el.append @titleEl

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @$el.attr('id', @model.get('id'))

    @setTitleView('show')

    @setFirstDay @model.firstDay
    @setDuration @model.duration

    return this
