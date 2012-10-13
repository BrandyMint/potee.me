class Potee.Views.Projects.EventView extends Backbone.View
  tagName: "div"
  className: "event"

  initialize: ->
    @render()

  render: ->
    @$el.css('margin-left', @calcOffset())
    return this

  calcOffset: ->
    daysDiff = moment(@model.date).diff(moment(@model.project_started_at), "days")
    daysOffset = daysDiff * window.router.dashboard.pixels_per_day

    time = moment(@model.time)
    timeDiff = (time.hours() * 60 + time.minutes()) / (24 * 60)
    timeOffset = window.router.dashboard.pixels_per_day * timeDiff

    return daysOffset + timeOffset
