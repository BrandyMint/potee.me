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
    eventDate = moment(@get('date')).endOf('day')
    today = moment().endOf('day')
    @passed = (eventDate).diff(today, 'days') < 0

  setDateTime: (datetime) ->
    @set({"date": datetime.toDate(), "time": datetime.toDate()})
    @date = @get("date")
    @time = @get("time")
    @setPassed()
    @view.rerender()