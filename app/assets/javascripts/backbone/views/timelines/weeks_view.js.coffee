Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.WeeksView extends Backbone.View
  template: JST["backbone/templates/timelines/weeks"]

  tagName: 'div'
  className: 'weeks'

  initialize: (options) ->
    @start = moment(options.date_start, "YYYY-MM-DD")
    @end = moment(options.date_finish, "YYYY-MM-DD")
    @columnWidth = options.column_width

  weeks: () ->
    weeks = []

    range = moment().range(@start.clone(), @end.clone())
    range.by("w", (m) =>
      if m < @end
        weeks.push(@week(m, m.clone().day(6)))
    )

    return weeks

  week: (start, end) ->
    width = (end.diff(start, "days") + 1) * @columnWidth - 1 # 1px на правую границу
    title = start.format("D.MM.YYYY") + " - " + end.format("D.MM.YYYY")
    return { width: width, title: title }

  index_of_current_week: ->
    moment().diff(moment(@start), 'weeks')

  render: =>
    $(@el).html(@template(weeks: @weeks(), current_week: @index_of_current_week()))
    return this
