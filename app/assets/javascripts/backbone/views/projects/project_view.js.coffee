Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Backbone.View
  template: JST["backbone/templates/projects/project"]
  tagName: "div"
  className: 'project'

  initialize: ->
    @model.view = this

  events:
    "click .destroy" : "destroy"
    "click .title" : "edit"
    "dblclick .progress .bar" : "add_event"

  add_event: (js_event) ->
    # FIXME [AK] why 50?
    timeline_cell = document.elementFromPoint(js_event.clientX, js_event.clientY - 50)
    projectEvents = new Potee.Collections.EventsCollection(project: @model)
    event = projectEvents.create(
      title: "Title of your event",
      date: timeline_cell.getAttribute('data-date'),
      time: timeline_cell.getAttribute('data-date') + " 12:00",
      project_id: @model.id)
    event_view = new Potee.Views.Projects.EventView(model: event)
    @$el.append(event_view.render().el)

  edit: ->
    @setTitleView 'edit'

  bounce: ->
    @$el.effect('bounce', {times: 5}, 200)

  destroy: () ->
    @model.destroy()
    @$el.fadeOut('fast', ->
      @remove
    )

    return false

  # Project's line left margin (when does it start)
  setLeftMargin: ->
    d = window.router.dashboard
    column_width = d.pixels_per_day
    @$el.css('margin-left', @model.first_item_by_scale("days") * column_width)

  # Project's line width
  setDuration: ->
    d = window.router.dashboard
    column_width = d.pixels_per_day
    @$el.css('width', @model.duration_in_days * column_width)

  setTitleView: (state)->

    if @titleView
      @titleEl = undefined
      @titleView.remove()

    switch state
      when 'show' then title_view_class = Potee.Views.Titles.ShowView
      when 'edit' then title_view_class = Potee.Views.Titles.EditView
      when 'new'  then title_view_class = Potee.Views.Titles.NewView

    options =
      project_view: this
      model: @model

    if @titleEl
      options['el'] = @titleEl

    @titleView = new title_view_class options
    @titleView.render()

    if !@titleEl
      @titleEl = @titleView.el
      @$el.append @titleEl

      # if state=='edit'

  render: ->
    @titleEl = undefined
    # TODO Вынести progressbar в отдельную вьюху?

    @$el.html(@template(@model.toJSON() ))
    @$el.attr('id', @model.cid)

    @model.projectEvents.each((event)=>
      event_view = new Potee.Views.Projects.EventView(model: event)
      @$el.append(event_view.render().el)
    )

    @setTitleView('show')

    @setLeftMargin()
    @setDuration()

    return this
