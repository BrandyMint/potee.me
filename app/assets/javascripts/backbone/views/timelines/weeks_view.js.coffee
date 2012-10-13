Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.WeeksView extends Backbone.View
  template: JST["backbone/templates/timelines/weeks"]

  tagName: 'div'
  className: 'weeks'
  range = undefined

  initialize: (date_start, date_finish) ->
    start = moment(date_start, "YYYY-MM-DD")
    end   = moment(date_finish, "YYYY-MM-DD")
    range = moment().range(start, end);

  weeks: () ->
    weeks = []
    # iterate by 1 week
    range.by "w", (moment) ->
      weeks.push(moment.clone().subtract('weeks', 1).format("dddd, MMMM Do") + " - " + moment.format("dddd, MMMM Do"))
    weeks

  render: =>
    $(@el).html(@template(weeks: @weeks()))
    return this