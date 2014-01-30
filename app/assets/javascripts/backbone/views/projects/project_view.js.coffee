Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Marionette.ItemView
  template: JST["backbone/templates/projects/project"]
  tagName: "div"
  className: 'project'
  modelEvents: () ->
    'destroy': @close

  initialize: ->
    _.extend @, Backbone.Events
    @model.view = this

  events:
    "click .title" : "title_click"
    "click .progress .bar" : "add_event"
    "mousedown": 'mousedown'

  mousedown: (e) ->
    @trigger 'select'
    if e.target == @$(".ui-resizable-e")[0]
      e.stopPropagation()

  add_event: (js_event) =>
    @trigger 'select'
    x = js_event.clientX - @$el.offset().left
    datetime = window.router.dashboard.datetimeAt(x + @leftMargin())
    event = @model.projectEvents.create
      date: datetime.toDate()
      time: datetime.toDate()
      project_id: @model.id

    eventElement = @renderEvent(event, x)
    eventElement.effect('bounce', {times: 3}, 150)
    @resetResizeMinWidth()

  title_click: (e) ->
    @trigger 'select'
    e.stopPropagation()
    if @titleView.sticky_pos == undefined
      @edit()
    else
      @gotoProjectEdge()

  edit: () ->
    @setTitleView 'edit'

  gotoProjectEdge:() ->
    dashboard_view = window.dashboard.view
    switch this.titleView.sticky_pos
      when 'left'
        project_finish = moment(this.model.get('finish_at')).toDate()
        dashboard_view.gotoDate(project_finish) 
      when 'right' 
        project_start = moment(this.model.get('started_at')).toDate() 
        dashboard_view.gotoDate(project_start)

  resetModel: (new_model) ->
    @undelegateEvents()
    @model = new_model
    @model.view = @
    @delegateEvents()
    @$el.attr 'id', @model.cid
    Backbone.pEvent.trigger 'savePositions'

  bounce: ->
    @$el.effect('bounce', {times: 5}, 200)

  remove: () ->
    @$el.slideUp 'fast', =>
      # Пересчет позиций нужно делать именно после пропадания проекта из DOM-а
      Backbone.pEvent.trigger 'savePositions'
      Backbone.pEvent.trigger 'resetStickyTitles'

    @stopListening()

  onClose: () ->
    @model.projectEvents.each (event) ->
      event.view.close() if event.view.close?

  onBeforeClose: () ->
    @$el.closest('div#projects').sortable("refresh")

  # Project's line left margin (when does it start)
  setLeftMargin: ->
    @$el.css('margin-left', @leftMargin())

  # Смещение полосы проекта относительно начала дэшборда.
  # @retrun [Number] смещение в пикселях.
  leftMargin: ->
    dashboardStart = moment(window.dashboard.min_with_span())
    offsetInDays = moment(@model.started_at).diff(dashboardStart, "days")
    return offsetInDays * window.dashboard.get('pixels_per_day')

  # Project's line width
  setDuration: ->
    @$el.css 'width', @width()

  width: ->
    return @model.duration() * window.dashboard.get('pixels_per_day')

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

  serializeData: ->
    return width: @width()

  onRender: ->
    # TODO Вынести progressbar в отдельную вьюху?

    @$el.attr('id', @model.cid)
    @$el.addClass('project-color-'+@model.get('color_index'))
    closest_event = @model.projectEvents.getClosestEvent()
    @model.projectEvents.each((event)=>
      current_event = @renderEvent(event)
      current_event.addClass('closest') if event == closest_event
    )

    @setTitleView 'show'

    @setLeftMargin()
    @setDuration()

    @$el.resizable
      grid: window.dashboard.get('pixels_per_day'),
      minWidth: @calculateResizeMinWidth()
      handles: 'e'
      stop: (event, ui) =>
        @durationChanged(ui.size.width)

    @

  resetResizeMinWidth: ->
    @$el.resizable("option", "minWidth", @calculateResizeMinWidth())

  calculateResizeMinWidth: ->
    if @model.projectEvents.length > 0
      date = ( @model.projectEvents.max (num) -> num.date).date
      date = moment(date).clone().add("days", 1)
      diff = date.diff(moment(@model.started_at), "days")
      return diff * window.dashboard.get('pixels_per_day')
    else
      return window.dashboard.get('pixels_per_day')

  durationChanged: (width) ->
    duration = Math.round(width / window.dashboard.get('pixels_per_day'))
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
    event.project.view.resetResizeMinWidth()

  stickTitle: (position = 'left') ->
    @.titleView.sticky_pos = position
    top_value = @$el.offset().top + 49 #отступ для каждого title
    title_dom = @.titleView.$el
    title_dom.addClass('sticky')
    title_dom.css({
      'top': top_value + 'px'
    })
    switch position
      when 'left'  then title_dom.css('left','0px')
      when 'right' then title_dom.css('right','0px')

  unstickTitle: () ->
    @.titleView.sticky_pos = undefined
    title_dom = @.titleView.$el
    title_dom.removeClass('sticky')
    title_dom.css({
      'top':'',
      'left':'',
      'right':''
    })

