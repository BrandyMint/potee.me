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
  initialize: (options) ->
    { @project, @project_view, @x } = options
    @mode = "show"
    @model.resetDate()
    @model.view = @

  modelEvents:
    'change:datetime': 'rerender'

  events:
    'keyup input'                : 'keyup'
    "click .event-title-el"      : "click"
    "click .event-bar"           : "click"
    "submit #edit-event"         : "update"
    "click #submit"              : "update"
    "click #cancel"              : "cancel"
    "click #destroy"             : "destroyEvent"
    "mouseenter .event-title-el" : "mouseenter"
    "mouseenter .event-bar"      : "mouseenter"
    "mouseleave .event-title-el" : "mouseleave"
    "mouseleave .event-bar"      : "mouseleave"
    "mousedown"                  : "mousedown"

  mousedown: (e) =>
    PoteeApp.seb.fire 'project:current', @project
    e.stopPropagation() # Непонято зачем это?

  click: (e) ->
    _.defer =>
      PoteeApp.seb.fire 'project:current', @project
    # Останаавливаем клик чтобы он не перешел выше где
    # dashboard его поймает и решил закрыть эту форму
    e.preventDefault()
    e.stopPropagation()
    # не редактируем если перетаскиваем.
    if @dragging
      @dragging = false
    else
      @setEditMode()

  isEditing: ->
    PoteeApp.reqres.request 'current_form:editing?'

  mouseenter: (e) ->
    return true if @isEditing()
    @$el.addClass 'event-handled'
    true

  mouseleave: (e) ->
    #e.stopPropagation()
    return true if @isEditing()
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

  cancel: (e) ->
    if e
      e.preventDefault()
      e.stopPropagation()

    view = @
    @trigger 'cancel'
    @$el.removeClass 'event-handled'
    @$el.find('form').fadeOut('fast')
    @setShowMode()

  destroyEvent: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.collection.remove @model
    @model.project.view.resetResizeMinWidth()

    @$el.fadeOut 'fast', =>
      # Нет смысла от сюда сбрасывать форму, потому что она сама сбросилась на закрытии
      # вьюхи: PoteeApp.vent.trigger 'current_form:set', undefined
      @remove()

  setEditMode: ->
    return true if @mode is 'edit'

    PoteeApp.vent.trigger 'current_form:set', @

    @mode = 'edit'
    @render()

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

  rerender: =>
    if @model.passed
      @$el.addClass 'passed'
    else
      @$el.removeClass 'passed'

  saveDateTime: (offset) ->
    @model.setDateTime window.timeline_view.momentAt offset
    @model.save()

    # TODO вынести на change:date_time в project_view
    @project_view.resetResizeMinWidth()

  setPosition: (x = undefined) ->
    @$el.css 'left', x || @calcOffset()

  onRender: ->
    if @mode is 'show'
      #@_bindDragEvents()
      @setShowMode()
      @$el.addClass 'passed' if @model.passed

      @setPosition @x

      @$el.draggable
        axis: 'x',
        containment: "parent",
        distance: '3',
        stop: (jsEvent, ui) =>
          @saveDateTime ui.position.left + @project_view.leftMargin()

          # Таким способом мы избавляемся от клика, который автоматически
          # приходит после отпускания мышки при драггинге
          # http://stackoverflow.com/questions/18032136/prevent-click-event-after-drag-in-jquery
          # http://stackoverflow.com/questions/1771627/preventing-click-event-with-jquery-drag-and-drop
          @dragging = true
          _.defer =>
            @dragging = false

      @$el.css "position", "absolute"
    else 
      #@_unbindDragEvents()
      @$el.addClass 'event-handled'
      @$el.find('input#title').focus()
      @$("form").backboneLink @model
      @$el.css 'z-index', ACTIVE_Z_INDEX

  # WARN Непонятно почему, но общий медиатор не ловит эскейпы когда редактируется форма
  # события
  keyup: (e) =>
    @cancel() if e.which == 27
