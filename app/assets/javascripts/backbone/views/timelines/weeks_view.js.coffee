Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.WeeksView extends Backbone.View
  template: JST["backbone/templates/timelines/weeks"]

  tagName: 'div'
  className: 'weeks'

  initialize: (options) ->
    @start = moment(options.date_start, "YYYY-MM-DD")
    @end = moment(options.date_finish, "YYYY-MM-DD")
    @columnWidth = options.column_width

  # Первую и последнуюю неделю рассчитываются отдельно, так как они не обязательно
  # начинаются в понедельник и заканчиваются в воскресенье.
  weeks: () ->
    weeks = []
    weeks.push(@week(@start, @start.clone().day(7)))

    range = moment().range(@start.clone().day(8), @end.clone().day(-7))
    range.by("w", (m) =>
      weeks.push(@week(m, m.clone().day(7)))
    )

    weeks.push(@week(@end.clone().day(1), @end))

    return weeks

  week: (start, end) ->
    width = (end.diff(start, "days") + 1) * @columnWidth - 1 # 1px на правую границу
    title = start.format("D.MM.YYYY") + " - " + end.format("D.MM.YYYY")
    return { width: width, title: title }

  render: =>
    $(@el).html(@template(weeks: @weeks()))
    return this
