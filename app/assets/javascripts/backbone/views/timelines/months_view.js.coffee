Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.MonthsView extends Marionette.ItemView
  template: "templates/timelines/months"

  tagName: 'div'
  className: 'months'

  initialize: (options) ->
    @start = moment options.date_start, "YYYY-MM-DD"
    @end = moment options.date_finish, "YYYY-MM-DD"

    # Добавляем месяцев справа, чтобы было куда продолжать и заполнить dashboard
    @end = @end.add "months", 12
    @columnWidth = options.column_width

  months: () ->
    months = []

    months.push @month(@start, @start.clone().endOf('month'))

    range = moment().range @start.clone().add("months", 1).startOf("month"),
                           @end.clone().subtract("months", 1).endOf("month")
    range.by 'M', (m) =>
      start = m.clone().startOf('month')
      end = m.clone().endOf('month')

      # Алгорит range.by работает таким образом, что последнее переданное
      # значение может быть больше конца интервала, поэтому приходится это
      # проверять.
      if end < @end
        months.push @month(start, end)

    months.push @month(@end.clone().startOf('month'), @end.clone().add("days", 1))

    return months

  month: (start, end) ->
    title = start.format('MMMM, YYYY')
    width = end.diff(start, "days") * @columnWidth - 1 # 1 px на правую границу
    return { title: title, width: width }

  index_of_current_month: ->
    moment().diff moment(@start), 'months'

  serializeData: ->
    months: @months()
    current_month: @index_of_current_month()
