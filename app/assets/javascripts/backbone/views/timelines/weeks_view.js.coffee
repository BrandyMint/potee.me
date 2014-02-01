Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.WeeksView extends Potee.Views.Timelines.BaseView
  template: "templates/timelines/weeks"

  className: 'weeks'
  columnRate: 7

  weeks: () ->
    weeks = []

    range = moment().range(@start.clone(), @end.clone())
    range.by("w", (m) =>
      if m < @end
        weeks.push(@week(m, m.clone().day(6)))
    )

    return weeks

  week: (start, end) ->
    month = start.format 'MMMM'
    end_month = end.format 'MMMM'

    unless month==end_month
      month += ' - ' + end_month

    details = start.format('D') + ' - ' + end.format('D')

    css_class = 'week'
    unless moment().diff(moment(start), 'weeks')
      css_class += ' current'

    # start.format("D.MM.YYYY") + " - " + end.format("D.MM.YYYY")
    res =
      width: (end.diff(start, "days") + 1) * @columnWidth() - 1 # 1px на правую границу
      month: month
      details: details
      css_class: css_class

    return res

  index_of_current_week: ->
    0

  serializeData: ->
    weeks: @weeks()
    current_week: @index_of_current_week()
