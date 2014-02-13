class Potee.Models.Project extends Backbone.Model
  MAX_COLOR_INDEX: 7
  paramRoot: 'project'
  events:
    "change:color_index" : "change_color"

  initialize: (attributes, options, startFrom = moment()) ->
    # TODO Передавать номер дня на котором кликнули создание проекта
    # от него и начинать
    @initNew startFrom.startOf("day") if @isNew()

    @setStartEndDates()

    @on 'remove', @remove_events

    @initProjectEventsCollection()

  initNew: (startFrom) ->
    @set 'color_index', window.projects.getNextColorIndex() if !@has('color_index')
    @set 'events', [] if !@has('events')

    @set 'started_at', startFrom.toString() if !@has('started_at')
    @set 'finish_at', moment(startFrom).add('days',7).toString() if !@has('finish_at')

  initProjectEventsCollection: ->
    # Свойство events используется для событий Backbone модели, поэтому
    # использовать его для обозначения списка событий не получается.
    @projectEvents = new Potee.Collections.EventsCollection project: @
    @projectEvents.reset @get("events")

    @unset 'events',
      silent: true

  defaults:
    title: 'Your project name'

  nextColor: ->
    @set 'color_index', ( @get('color_index') + 1 ) % @MAX_COLOR_INDEX
    @save()

  toJSON: ->
    res = super(this)
    res['cid'] = @cid

    return res

  setStartEndDates: ->
    @started_at = moment(@get("started_at")).toDate()
    @finish_at  = moment(@get("finish_at")).toDate()

  middleMoment: ->
    moment(@started_at).add @duration()/2, 'days'

  duration: ->
    return moment(@finish_at).diff(moment(@started_at), "days") + 1

  # duration - количество дней
  setDuration: (duration) ->
    finishAt = moment(@started_at).clone().add("days", duration - 1)

    @set("finish_at", finishAt.format("YYYY-MM-DD"))
    @save()
    @setStartEndDates()

    return

