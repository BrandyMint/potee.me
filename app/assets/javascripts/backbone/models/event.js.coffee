class Potee.Models.Event extends Backbone.Model
  paramRoot: "event"

  defaults:
    title: "Some event"

  initialize: ->
    @date = moment(@get("date")).toDate()
    @time = moment(@get("time")).toDate()
    @project = @collection.project
    @project_started_at = @collection.project.started_at
    @setPassed()

  resetDate: ->
    @date = moment(@get("date")).toDate()

  setPassed: ->
    eventDate = moment(@get('date')).eod()
    today = moment().eod()
    @passed = (eventDate).diff(today, 'days') < 0

  setDateTime: (datetime) ->
    @set("date", datetime.toDate())
    @set("time", datetime.toDate())
    @setPassed()
    @view.rerender()

  toTemplate: ->
    @toJSON()

class Potee.Collections.EventsCollection extends Backbone.Collection
  model: Potee.Models.Event
  url: '/events'

  initialize: (options) ->
    @on 'remove', (model) ->
      model.destroy()
    @project = options.project

  getClosestEvent: () ->
    diff_seconds = 31536000 #количество секунд в году, пойдет для первоначального значения
    closest_event = this.last
    this.each((event) =>
      diff = Math.abs(moment(event.date).diff(moment(), "seconds")) 
      if diff < diff_seconds  
        closest_event = event
        diff_seconds = diff
    )
    return closest_event
