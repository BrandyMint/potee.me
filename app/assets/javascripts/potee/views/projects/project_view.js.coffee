Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Marionette.ItemView
  INACTIVE_OPACITY: 0.4
  template: "templates/projects/project"
  className: 'project'
  modelEvents:  ->
    'destroy': @close

  initialize: ->
    _.extend @, Backbone.Events
    @dashboard_view = window.dashboard_view
    @model.view = @
    @$projects = $('#projects')

  _clickOutside: (e) =>
    if $(e.target).closest(@$el).length == 0
      PoteeApp.seb.fire 'project:current', undefined if PoteeApp.seb.get('project:current') == @model

  events:
    #"click .title" : "title_click"
    'click'        : 'click'
    #"dblclick .progress .bar" : "add_event"
    "dblclick" : "add_event"
    "mousedown": 'mousedown'

  click: ->
    @bounce()
    PoteeApp.seb.fire 'project:current', @model

  mousedown: (e) ->
    if e.target == @$(".ui-resizable-e")[0]
      e.stopPropagation()

  correctOpacity: (options = {}) ->
    { moving } = options
    total_height = @$projects.height()

    project_height = @$el.height()

    min_top = 20

    max_top = total_height - project_height

    top = @$el.position().top

    console.log moving

    if moving is 'up'
      if top < min_top
        action = 'sunset'
      else if top > max_top
        action = 'sunrise'
      else
        action = 'middle'
    else if moving is 'down'
      if top < min_top
        action = 'sunrise'
      else if top > max_top
        action = 'sunset'
      else
        action = 'middle'

    window.clearTimeout @_opacityTimer if @_opacityTimer?

    if action is 'middle' or action is 'sunrise'
      @setOpacity 1

    return if action is 'middle'

    timeout = 500

    if action is 'sunrise' && top < 30
      action = 'sunset'
      timeout = 1500

    switch action
      when 'sunrise' then callback = @forceVisibility
      when 'sunset'  then callback = @forceInvisibility

    @_opacityTimer = window.setTimeout callback, timeout

    return

    if top >= max_top
      x = 30 - (top - max_top)
      x = 0 if x < 0
      @setOpacity x/30, action
    else if top > 30 && top < max_top
      @setOpacity 1, action
    else if top < 3 || top > max_top
      @setOpacity 0, action
    else if top < 30
      @setOpacity top/30, action

  setOpacity: (o, action) ->
    if @_inactive
      max = @INACTIVE_OPACITY
    else
      max = 1

    opacity = parseInt @$el.css 'opacity'

    console.log opacity,o,action if @model.id == 302

    if action is 'sunrise'
      return if o<=opacity
    else if action is 'sunset'
      return if o>=opacity

    o = max if o>max
    @$el.css opacity: o

    if o<max
      window.clearTimeout @_opacityTimer if @_opacityTimer?
      if o>0.6
        @_opacityTimer = window.setTimeout @forceVisibility, 1000
      else
        @_opacityTimer = window.setTimeout @forceInvisibility, 1000

  forceInvisibility: =>
    @$el.animate { opacity: 0 },
      easing: 'easeInBounce'
      duration: 500
      #always: =>
        #window.projects_view.scrollTop @$el.position().top + @$el.height() + 1

  forceVisibility: =>
    @$el.animate { opacity: @demOpacity() },
      easing: 'easeOutQuint'
      duration: 300

  demOpacity: ->
    if @_inactive
      @INACTIVE_OPACITY
    else
      1

  add_event: (js_event) =>
    return false if PoteeApp.request 'current_form:editing?'

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
    @$el.effect 'bounce', {times: 5}, 200

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
      when 'edit' then return
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
    @correctOpacity()
    @setLeftMargin()
    @resetEventsPositions()
    @setWidth()

  resetEventsPositions: =>
    async.each @model.projectEvents, (event) ->
      event.view.setPosition()

  setClosestEvent: ->
    first_event = @model.projectEvents.getFirstEvent()
    @model.projectEvents.each (event)=>
      current_event = @renderEvent event
      current_event.addClass 'closest'  if event == first_event

  onRender: ->
    # TODO Вынести progressbar в отдельную вьюху?

    @titleRegion = new Marionette.Region el: @$('.project-title')

    @$el.attr 'id', @model.cid
    @$el.removeClass 'project-color-' + @model.previous 'color_index'
    @$el.addClass 'project-color-' + @model.get 'color_index'

    @setClosestEvent()

    if @isNew()
      @setTitleView 'new'
    else
      @setTitleView 'show'

    @setLeftMargin()
    @setWidth()

    @$el.resizable
      grid: window.dashboard.get('pixels_per_day'),
      minWidth: @_getResizeMinWidth()
      handles: 'e'
      start: =>
        _.defer =>
          PoteeApp.seb.fire 'project:current', @model

      stop: (event, ui) =>
        @changeDuration ui.size.width

    @correctOpacity()

    $("#viewport").bind 'click', @_clickOutside

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
      project: @model
      project_view: @
      x: x # Координаты нового эвента

    @$el.append event_view.render().$el

    event_view.$el

  inactive: ->
    @_inactive = true
    _.defer =>
      @$el.animate { opacity: @INACTIVE_OPACITY },
        duration: 100

  active: ->
    @_inactive = false
    _.defer =>
      @$el.animate { opacity: 1 },
        easing: 'easeOutQuint'
        duration: 300

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
