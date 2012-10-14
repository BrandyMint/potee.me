Potee.Views.Events ||= {}

class Potee.Views.Events.EventView extends Backbone.View
  template: JST["backbone/templates/events/event"]
  tagName: "div"
  className: "event"

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
    @$el.html @template( @model.toJSON() )
    @$el.css('margin-left', @calcOffset())
    return this
