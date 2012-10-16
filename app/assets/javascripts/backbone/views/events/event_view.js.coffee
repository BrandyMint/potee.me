Potee.Views.Events ||= {}

class Potee.Views.Events.EventView extends Backbone.View
  template_show: JST["backbone/templates/events/event"]
  template_edit: JST["backbone/templates/events/edit"]
  tagName: "div"
  className: "event"

  events:
    "click .event-title" : "edit"
    "submit #edit-event" : "update"
    "click #submit"        : "update"
    'click #cancel'         : 'cancelEvent'
    'click #destroy'        : 'destroyEvent'
    'mouseenter'            : 'mouseenter'
    'mouseleave'            : 'mouseleave'

  mouseenter: (e) ->
    #e.stopPropagation()
    #return if window.dashboard.view.currentForm
    @$el.addClass('event-handled')
    @$el.bind 'mouseover', (e)->
      e.stopPropagation()

  mouseleave: (e) ->
    #e.stopPropagation()
    #return if window.dashboard.view.currentForm
    @$el.removeClass('event-handled')
    @$el.unbind 'mouseover'
    @cancelEvent(e)

  update: (e)->
    e.preventDefault()
    e.stopPropagation()

    title = @$el.find('input#title').attr("value")
    @model.set("title", title)

    @model.save(null,
      success : (model) =>
        @model = model

        @renderShow()
        # window.location.hash = "/#{@model.id}"
    )


  cancelEvent: (e)->
    e.preventDefault()
    e.stopPropagation()
    window.dashboard.view.setCurrentForm undefined
    # @cancel()

  cancel: ->
    view = this
    @$el.find('form').fadeOut('fast')
    @model.fetch
      success: (model) ->
        model.view = view
        view.model = model
        view.renderShow()

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
    @$el.html @template_edit @model.toJSON()
    @$el.find('input#title').focus()
    @.$("form").backboneLink(@model)

  renderShow: ->
    return true if @mode == 'show'

    @mode = 'show'
    @$el.html @template_show @model.toJSON()

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

  render: ->
    @renderShow()
    @$el.css('left', @options.x || @calcOffset())
    return this
