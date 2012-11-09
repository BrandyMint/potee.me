Potee.Views.Events ||= {}

class Potee.Views.Events.EventView extends Backbone.View
  template_show: JST["backbone/templates/events/event"]
  template_edit: JST["backbone/templates/events/edit"]
  tagName: "div"
  className: "event"

  DEFAULT_Z_INDEX = 150
  ACTIVE_Z_INDEX = 200

  initialize: ->
    @model.resetDate()
    @model.view = @
    @setDragDetector()

  events:
    "click .event-title-el" : "onclick"
    "click .event-bar" : "onclick"
    'mousedown' : (e)->
      e.stopPropagation()
    "submit #edit-event" : "update"
    "click #submit"      : "update"
    'click #cancel'      : 'cancelEvent'
    'click #destroy'     : 'destroyEvent'
    'mouseenter .event-title-el'  : 'mouseenter'
    'mouseenter .event-bar'       : 'mouseenter'
    'mouseleave .event-title-el'  : 'mouseleave'
    'mouseleave .event-bar'       : 'mouseleave'


  onclick: (e) ->
    # Останаавливаем клик чтобы он не перешел выше где
    # dashboard его поймает и решил закрыть эту форму
    e.preventDefault()
    e.stopPropagation()
    # не редактируем если перетаскиваем.
    if @dragging
      @dragging = false
    else
      @edit()

  mouseenter: (e) ->
    return true if window.dashboard.view.currentForm
    @$el.addClass('event-handled')
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
    @model.set("title", title)

    @model.save(null,
      success : (model) =>
        @model = model

        @renderShow()
    )


  cancelEvent: (e)->
    e.preventDefault()
    e.stopPropagation()
    window.dashboard.view.setCurrentForm undefined

  cancel: ->
    view = this
    @$el.removeClass('event-handled')
    @$el.find('form').fadeOut('fast')
    @renderShow()

  destroyEvent: (e)->
    e.preventDefault()
    e.stopPropagation()
    @model.collection.remove @model

    @$el.fadeOut('fast', =>
      @remove()
      window.dashboard.view.currentForm = undefined
    )

  renderEdit: ->
    return true if @mode == 'edit'

    window.dashboard.view.setCurrentForm this

    @mode = 'edit'
    @$el.html @template_edit @model.toTemplate()
    @$el.addClass('event-handled')
    @$el.find('input#title').focus()
    @.$("form").backboneLink(@model)
    @$el.css('z-index', ACTIVE_Z_INDEX)

  renderShow: ->
    return true if @mode == 'show'

    @mode = 'show'
    @$el.html @template_show @model.toTemplate()
    @$el.css('z-index', DEFAULT_Z_INDEX)

  edit: ->
    @renderEdit()

  calcOffset: ->
    d = window.router.dashboard
    columnWidth = d.pixels_per_day
    diff = moment(@model.date).diff(moment(@model.project_started_at), "days")
    daysOffset  = diff * columnWidth

    time        = moment(@model.time)
    timeDiff    = (time.hours() * 60 + time.minutes()) / (24 * 60)
    timeOffset  = columnWidth * timeDiff

    Math.round(daysOffset + timeOffset)

  rerender: ->
    if @model.passed
      @$el.addClass('passed')
    else
      @$el.removeClass('passed')


  render: ->
    @renderShow()
    @$el.addClass('passed') if @model.passed
    @$el.css('left', @options.x || @calcOffset())
    return this

  setDragDetector: ->
    @$el.mousedown =>
      @mousedown = true
    $(document).mousemove =>
      @dragging = true if @mousedown
    $(document).mouseup =>
      @mousedown = false



