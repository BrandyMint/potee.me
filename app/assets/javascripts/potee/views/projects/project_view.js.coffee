Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Marionette.ItemView
  template: "templates/projects/project"
  className: 'project'
  modelEvents: () ->
    'destroy': @close

  initialize: ->
    _.extend @, Backbone.Events
    @dashboard_view = window.dashboard_view
    @model.view = @
    $(document).bind 'click', @_clickOutside

  _clickOutside: (e) =>
    if $(e.target).closest(@$el).length == 0
      PoteeApp.seb.fire 'project:current', undefined if PoteeApp.seb.get('project:current') == @model

  events:
    "click .title" : "title_click"
    "dblclick .progress .bar" : "add_event"
    "mousedown": 'mousedown'

  mousedown: (e) ->
    PoteeApp.seb.fire 'project:current', @model
    if e.target == @$(".ui-resizable-e")[0]
      e.stopPropagation()

  add_event: (js_event) =>
    PoteeApp.seb.fire 'project:current', @model
    x = js_event.clientX - @$el.offset().left
    datetime = window.timeline_view.momentAt x + @leftMargin()
    event = @model.projectEvents.create
      date: datetime.toDate()
      time: datetime.toDate()
      project_id: @model.id

    eventElement = @renderEvent event, x
    eventElement.effect('bounce', {times: 3}, 150)
    @resetResizeMinWidth()

  title_click: (e) ->
    PoteeApp.seb.fire 'project:current', @model
    e.stopPropagation()
    if @titleView.sticky_pos == undefined
      @edit()
    else
      @gotoProjectEdge()

  edit: () ->
    @setTitleView 'edit'

  gotoProjectEdge:() ->
    switch @titleView.sticky_pos
      when 'left'
        PoteeApp.commands.execute 'gotoDate', @model.finish_at
      when 'right' 
        PoteeApp.commands.execute 'gotoDate', @model.started_at

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

  onClose: ->
    $(document).unbind 'click', @_clickOutside
    @model.projectEvents.each (event) ->
      event.view.close() if event.view.close?

  onBeforeClose: ->
    @$el.closest( window.projects_view.$el ).sortable("refresh")

  # Project's line left margin (when does it start)
  setLeftMargin: =>
    @$el.css 'margin-left', @leftMargin()
    #@$el.offset left: @leftMargin()

  #leftOffsetInDays: ->
    #moment(@model.started_at).diff window.timeline_view.startDate(), "days"

  # Смещение полосы проекта относительно начала дэшборда.
  # @retrun [Number] смещение в пикселях.
  leftMargin: ->
    window.timeline_view.offsetInPixels @model.started_at
    #@leftOffsetInDays() * window.dashboard.get('pixels_per_day')

  # Project's line width
  setWidth: =>
    @$el.css 'width', @width()

  width: ->
    @model.duration() * window.dashboard.get('pixels_per_day')

  setTitleView: (state)->
    @state = state
    switch state
      when 'show' then title_view_class = Potee.Views.Titles.ShowView
      when 'edit' then title_view_class = Potee.Views.Titles.EditView
      when 'new'  then title_view_class = Potee.Views.Titles.NewView

    @titleView = new title_view_class
      project_view: @
      model: @model

    #@titleView.on 'dom:refresh', (a) =>
      #debugger

    @titleRegion.show @titleView

    # Событие должно генерироваться после вставки вьюхи в реальный DOM
    if state == 'edit' or state == 'new'
      PoteeApp.vent.trigger 'current_form:set', @titleView

  serializeData: ->
    return width: @width()

  resetScale: ->
    @setLeftMargin()
    @resetEventsPositions()
    @setWidth()

  resetEventsPositions: =>
    async.each @model.projectEvents, (event) ->
      event.view.setPosition()

  onRender: ->
    # TODO Вынести progressbar в отдельную вьюху?

    @titleRegion ||= new Marionette.Region el: @$('.project-title')

    @$el.attr 'id', @model.cid
    @$el.addClass 'project-color-'+@model.get('color_index')

    closest_event = @model.projectEvents.getClosestEvent()
    @model.projectEvents.each (event)=>
      current_event = @renderEvent event
      current_event.addClass('closest') if event == closest_event

    if @isNew()
      @setTitleView 'new'
    else
      @setTitleView 'show'

    @setLeftMargin()
    @setWidth()

    @$el.resizable
      # grid: window.dashboard.get('pixels_per_day')
      minWidth: @_getResizeMinWidth()
      #autoResize: '#projects-container'
      handles: 'e'
      #ghost: true
      resize: (event, ui) =>
        if event.pageX > window.viewport.width() - window.timeline_view.columnWidth()
          console.log event.pageX
          window.viewport.animate { scrollLeft: window.viewport.scrollLeft() + window.timeline_view.columnWidth() },
            duration: 200,
            easing: 'easeInOutExpo',

        #@leftMargin
        #@$el.
        #ui.originalElement
        #debugger
        #console.log ui.size
      stop: (event, ui) =>
        @changeDuration ui.size.width

    @

  onScroll: (e)=>
    console.log e

  isEditing: ->
    @state != 'show'

  isNew: ->
    @model.isNew()

  resetResizeMinWidth: ->
    @$el.resizable "option", "minWidth", @_getResizeMinWidth()

  _getResizeMinWidth: ->
    if @model.projectEvents.length > 0
      date = ( @model.projectEvents.max (num) -> num.date).date
      date = moment(date).clone().add("days", 1)
      diff = date.diff moment(@model.started_at), "days"
      return diff * window.dashboard.get('pixels_per_day')
    else
      return window.dashboard.get 'pixels_per_day'

  changeDuration: (width) ->
    duration = Math.round(width / window.dashboard.get('pixels_per_day'))
    @model.setDuration duration

    totalWidth = @width() + @leftMargin()
    if totalWidth > @dashboard_view.width()
      Backbone.pEvent.trigger 'dashboard:stretch'

  renderEvent: (event, x = undefined) ->
    event_view = new Potee.Views.Events.EventView
      model: event
      project_view: @
      x: x

    @$el.append event_view.render().$el

    event_view.$el

  stickTitle: (position = 'left') ->
    @.titleView.sticky_pos = position
    top_value = @$el.offset().top + 49 #отступ для каждого title
    title_dom = @.titleView.$el
    title_dom.addClass('sticky')
    title_dom.css
      top: top_value + 'px'

    switch position
      when 'left'  then title_dom.css('left','0px')
      when 'right' then title_dom.css('right','0px')

  unstickTitle: ->
    @.titleView.sticky_pos = undefined
    title_dom = @.titleView.$el
    title_dom.removeClass('sticky')
    title_dom.css
      top:  ''
      left: ''
      right:''
