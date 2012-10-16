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
    month = start.format('MMMM YYYY')
    end_month = end.format('MMMM YYYY')

    unless month==end_month
      month += ' - ' + end_month

    details = start.format('D') + ' - ' + end.format('D')

    css_class = 'week'
    unless moment().diff(moment(start), 'weeks')
      css_class += ' current'

    # start.format("D.MM.YYYY") + " - " + end.format("D.MM.YYYY")
    res =
      width: (end.diff(start, "days") + 1) * @columnWidth - 1 # 1px на правую границу
      month: month
      details: details
      css_class: css_class

    return res

  index_of_current_week: ->

  render: =>
    $(@el).html @template( weeks: @weeks() )
    return this
