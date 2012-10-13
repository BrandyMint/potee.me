Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.MonthsView extends Backbone.View
  template: JST["backbone/templates/timelines/months"]

  tagName: 'div'
  className: 'months'
  range = undefined

  initialize: (date_start, date_finish) ->
    start = moment(date_start, "YYYY-MM-DD")
    end   = moment(date_finish, "YYYY-MM-DD")
    range = moment().range(start, end);

  months: () ->
    months = []
    # iterate by 1 month
    range.by "m", (moment) ->
      months.push(moment.format("MMMM, YYYY"))
    months

  render: =>
    $(@el).html(@template(months: @months()))
    return this