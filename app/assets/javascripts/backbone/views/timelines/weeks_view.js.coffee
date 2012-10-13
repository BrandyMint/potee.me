Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.WeeksView extends Backbone.View
  template: JST["backbone/templates/timelines/weeks"]

  tagName: 'div'
  className: 'weeks'

  initialize: (options) ->
    start = moment(options.date_start, "YYYY-MM-DD")
    end   = moment(options.date_finish, "YYYY-MM-DD")
    @range = moment().range(start.day(0), end.day(6));
    @column_width = options.column_width

  weeks: () ->
    weeks = []
    # iterate by 1 week
    @range.by "w", (moment) ->
      weeks.push(moment.format("dddd, MMMM Do") + " - " + moment.clone().add('weeks', 1).subtract('days', 1).format("dddd, MMMM Do"))
    weeks

  set_column_width: () ->
    days_in_week = 7
    @$el.find('table td').attr('width', @column_width * days_in_week + "px")

  render: =>
    $(@el).html(@template(weeks: @weeks()))
    @set_column_width()
    return this