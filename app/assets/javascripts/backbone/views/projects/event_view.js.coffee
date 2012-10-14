class Potee.Views.Projects.EventView extends Backbone.View
  tagName: "div"
  className: "event"

  calcOffset: ->
    d = window.router.dashboard
    column_width = d.pixels_per_day * @model.days_to_scale(d.get("scale"))
    diff = moment(@model.date).diff(moment(@model.project_started_at), d.get("scale"))
    daysOffset  = diff * column_width

    time        = moment(@model.time)
    timeDiff    = (time.hours() * 60 + time.minutes()) / (24 * 60)
    timeOffset  = column_width * timeDiff

    Math.round(daysOffset + timeOffset)

  render: ->
    @$el.css('margin-left', @calcOffset())
    return this