Potee.Views.Events ||= {}

class Potee.Views.Events.EventView extends Marionette.ItemView
  DEFAULT_Z_INDEX = 150
  ACTIVE_Z_INDEX = 200

  getTemplate: ->
    if @mode is "show"
      return "templates/events/event"
    else
      return "templates/events/edit"

  className: "event"
  initialize: (@options) ->
    @mode = "show"
    @model.resetDate()
    @model.view = @
    @setDragDetector()

  events:
    "click .event-title-el"      : "click"
    "click .event-bar"           : "click"
    "submit #edit-event"         : "update"
    "click #submit"              : "update"
    "click #cancel"              : "cancelEvent"
    "click #destroy"             : "destroyEvent"
    "mouseenter .event-title-el" : "mouseenter"
    "mouseenter .event-bar"      : "mouseenter"
    "mouseleave .event-title-el" : "mouseleave"
    "mouseleave .event-bar"      : "mouseleave"
    "mousedown"                  : (e) -> e.stopPropagation()

  click: (e) ->
    # Останаавливаем клик чтобы он не перешел выше где
    # dashboard его поймает и решил закрыть эту форму
    e.preventDefault()
    e.stopPropagation()
    # не редактируем если перетаскиваем.
    if @dragging
      @dragging = false
    else
      @setEditMode()

  mouseenter: (e) ->
    return true if window.dashboard.view.currentForm
    @$el.addClass 'event-handled'
    true

  mouseleave: (e) ->
    #e.stopPropagation()
    return true if window.dashboard.view.currentForm
    return true if @$el.hasClass('ui-draggable-dragging')
    if @$el.hasClass('event-handled')
      @$el.removeClass('event-handled')
      # @$el.unbind 'mouseover'
      # @cancelEvent(e)
    true

  update: (e)->
    e.preventDefault()
    e.stopPropagation()

    title = @$el.find('input#title').attr("value")
    @model.set "title", title

    @model.save(null,
      success : (model) =>
        @model = model
        @model.project.view.resetResizeMinWidth()
        @setShowMode()
    )

  cancelEvent: (e) ->
    e.preventDefault()
    e.stopPropagation()
    window.dashboard.view.setCurrentForm undefined

  cancel: ->
    view = @
    @$el.removeClass 'event-handled'
    @$el.find('form').fadeOut('fast')
    @setShowMode()

  destroyEvent: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.collection.remove @model
    @model.project.view.resetResizeMinWidth()

    @$el.fadeOut('fast', =>
      @remove()
      window.dashboard.view.currentForm = undefined
    )

  setEditMode: ->
    return true if @mode is 'edit'

    window.dashboard.view.setCurrentForm @

    @mode = 'edit'
    @render()

    @$el.addClass 'event-handled'
    @$el.find('input#title').focus()
    @$("form").backboneLink @model
    @$el.css 'z-index', ACTIVE_Z_INDEX

  setShowMode: ->
    return true if @mode is 'show'

    @mode = 'show'
    @render()
    @$el.css 'z-index', DEFAULT_Z_INDEX

  calcOffset: ->
    d           = window.dashboard
    columnWidth = d.get 'pixels_per_day'
    diff        = moment(@model.date).diff(moment(@model.project_started_at), "days")
    daysOffset  = diff * columnWidth

    time        = moment @model.time
    timeDiff    = (time.hours() * 60 + time.minutes()) / (24 * 60)
    timeOffset  = columnWidth * timeDiff

    Math.round daysOffset + timeOffset

  rerender: ->
    if @model.passed
      @$el.addClass 'passed'
    else
      @$el.removeClass 'passed'

  saveDateTime: (offset) ->
    datetime = window.dashboard.datetimeAt offset
    @model.setDateTime datetime
    @model.save()

    # TODO вынести на change:date_time в project_view
    @options.project_view.resetResizeMinWidth()

  setPosition: (x = undefined) ->
    @$el.css 'left', x || @calcOffset()

  onRender: ->
    unless @mode is "edit"
      @setShowMode()
      @$el.addClass 'passed'  if @model.passed

      @setPosition @options.x

      @$el.draggable
        axis: 'x',
        containment: "parent",
        distance: '3',
        stop: (jsEvent, ui) =>
          @saveDateTime ui.position.left + @options.project_view.leftMargin()

      @$el.css "position", "absolute"

  setDragDetector: ->
    @$el.mousedown =>
      @mousedown = true
    $(document).mousemove =>
      @dragging = true if @mousedown
    $(document).mouseup =>
      @mousedown = false
