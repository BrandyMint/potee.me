Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.WeeksView extends Potee.Views.Timelines.BaseView
  template: "templates/timelines/weeks"

  className: 'weeks'
  columnRate: 7

  startDate: ->
    moment(@projects.firstDate()).clone().day(0)

  finishDate: ->
    @_finishDate().add 'weeks', @_extraWeeks()

  _extraWeeks: ->
    offset = @offsetInPixels @_finishDate()
    extra_weeks_pixels = window.viewport.width() - offset

    minimal = @columnWidth() * 1.5
    extra_weeks_pixels = minimal if extra_weeks_pixels<minimal
    extra_week = Math.round extra_weeks_pixels/@columnWidth()
    extra_week = 1 if extra_week < 1

    extra_week


  _finishDate: ->
    moment(@projects.lastDate()).clone().day(6)

  columns_count: ->
    @weeks_count()

  weeks_count: ->
    @weeks.length

  # TODO кешировать недели, сбрасывать при resetScale
  weeks: () ->
    weeks = []

    range = moment().range @startDate(), @finishDate()
    range.by("w", (m) =>
      if m < @finishDate()
        weeks.push @week(m, m.clone().day(6))
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
    # TODO
    0

  serializeData: ->
    weeks: @weeks()
    current_week: @index_of_current_week()
