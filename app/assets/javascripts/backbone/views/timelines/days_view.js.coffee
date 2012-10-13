Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.DaysView extends Backbone.View
  template: JST["backbone/templates/timelines/days"]

  tagName: 'div'
  className: 'days'
  range = undefined

  initialize: (date_start, date_finish) ->
    start = moment(date_start, "YYYY-MM-DD")
    end   = moment(date_finish, "YYYY-MM-DD")
    range = moment().range(start, end);

  days: () ->
    days = []
    # iterate by 1 day
    range.by "d", (moment) ->
      days.push(moment.format("dddd, MMMM Do"))
    days

  render: =>
    $(@el).html(@template(days: @days()))
    return this