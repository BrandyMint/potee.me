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
    'click #cancel'        : 'cancelEvent'
    'click #destroy'       : 'destroyEvent'
    'mouseenter'            : 'mouseenter'
    'mouseleave'            : 'mouseleave'

  mouseenter: (e) ->
    @$el.addClass('event-handled')
    @$el.bind 'mouseover', (e)->
      e.stopPropagation()

  mouseleave: (e) ->
    @$el.removeClass('event-handled')
    @$el.unbind 'mouseover'
    @cancel()

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

  on_keypress: (e) ->
    e ||= window.event
    if e.keyCode == 27
      @cancel()

  cancelEvent: (e)->
    e.preventDefault()
    e.stopPropagation()
    @cancel()

  cancel: ->
    view = this
    $(document).unbind('keydown')
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
    @$el.fadeOut('fast', ->
      @remove
    )

  renderEdit: ->
    return true if @mode == 'edit'

    _.bindAll(this, 'on_keypress');
    $(document).bind('keydown', this.on_keypress);

    @mode = 'edit'
    @$el.html @template_edit @model.toJSON()
    @$el.find('input#title').focus()
    @.$("form").backboneLink(@model)

  renderShow: ->
    return true if @mode == 'show'
    @$el.html @template_show @model.toJSON()
    @mode = 'show'

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
