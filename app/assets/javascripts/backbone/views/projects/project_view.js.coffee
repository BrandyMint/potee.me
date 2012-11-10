Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Backbone.View
  template: JST["backbone/templates/projects/project"]
  tagName: "div"
  className: 'project'

  initialize: ->
    @model.view = this

  events:
    "click .title" : "edit"
    "click .progress .bar" : "add_event"
    "mousedown": (e)->
      if e.target == @$(".ui-resizable-e")[0]
        e.stopPropagation()

  add_event: (js_event) ->
    x = js_event.clientX - @$el.offset().left
    datetime = window.router.dashboard.datetimeAt(x + @leftMargin())
    event = @model.projectEvents.create(
      date: datetime.toDate(),
      time: datetime.toDate(),
      project_id: @model.id)

    eventElement = @renderEvent(event, x)
    eventElement.effect('bounce', {times: 3}, 150)
    @$el.resizable("option", "minWidth", @minWidthForResize())

  edit: (e)->
    e.stopPropagation()
    @setTitleView 'edit'

  bounce: ->
    @$el.effect('bounce', {times: 5}, 200)

  destroy: () ->
    window.projects.remove @model
    @$el.slideUp('fast', ->
      @remove
    )
    @$el.closest('div#projects').sortable("refresh")
    false


  # Project's line left margin (when does it start)
  setLeftMargin: ->
    @$el.css('margin-left', @leftMargin())

  # Смещение полосы проекта относительно начала дэшборда.
  # @retrun [Number] смещение в пикселях.
  leftMargin: ->
    dashboardStart = moment(window.dashboard.min_with_span())
    offsetInDays = moment(@model.started_at).diff(dashboardStart, "days")
    return offsetInDays * window.dashboard.pixels_per_day

  # Project's line width
  setDuration: ->
    @$el.css('width', @width())

  width: ->
    return @model.duration() * window.dashboard.pixels_per_day

  setTitleView: (state)->
    switch state
      when 'show' then title_view_class = Potee.Views.Titles.ShowView
      when 'edit' then title_view_class = Potee.Views.Titles.EditView
      when 'new'  then title_view_class = Potee.Views.Titles.NewView

    options =
      project_view: this
      model: @model

    if @titleView
      @titleView.remove()

    @titleView = new title_view_class options
    @$el.append @titleView.render().el
    window.dashboard.view.cancelCurrentForm()
    window.dashboard.view.setCurrentForm @titleView unless state == 'show'

    @$el.find('input#title').focus()

    @bounce() if state == 'new'

  render: ->
    # TODO Вынести progressbar в отдельную вьюху?

    @$el.html(@template(width: @width()))
    @$el.attr('id', @model.cid)
    @$el.addClass('project-color-'+@model.get('color_index'))

    @model.projectEvents.each((event)=>
      @renderEvent(event)
    )

    @setTitleView('show')

    @setLeftMargin()
    @setDuration()

    @$el.resizable(
      grid: window.dashboard.pixels_per_day,
      minWidth: @minWidthForResize()
      handles: 'e'
      stop: (event, ui) =>
        @durationChanged(ui.size.width)
    )

    return this

  minWidthForResize: ->
    lastEvent = @model.projectEvents.last() || null
    if lastEvent == null
      return window.dashboard.pixels_per_day
    else
      date = moment(lastEvent.date).clone().add("days", 1)
      diff = date.diff(moment(@model.started_at), "days")
      return diff * window.dashboard.pixels_per_day

  durationChanged: (width) ->
    duration = Math.round(width / window.dashboard.pixels_per_day)
    @model.setDuration(duration)

    totalWidth = @width() + @leftMargin()
    if totalWidth > window.dashboard.width()
      dashboard.findStartEndDate()
      dashboard.view.update()

  renderEvent: (event,x = undefined) ->
    event_view = new Potee.Views.Events.EventView
      model: event
      x: x

    @$el.append event_view.render().$el

    event_view.$el.draggable(
      axis: 'x',
      containment: "parent",
      distance: '3',
      stop: (jsEvent, ui) =>
        @eventDateTimeChanged(event, ui.position.left + @leftMargin())
    )

    event_view.$el.css("position", "absolute")
    return event_view.$el

  eventDateTimeChanged: (event, offset) ->
    datetime = window.dashboard.datetimeAt(offset)
    event.setDateTime(datetime)
    event.save()

