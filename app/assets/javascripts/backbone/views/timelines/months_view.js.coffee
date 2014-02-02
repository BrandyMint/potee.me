Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.MonthsView extends Potee.Views.Timelines.BaseView
  template: "templates/timelines/months"

  className: 'months'
  columnRate: 30

  startDate: ->
    moment(@projects.firstDate()).clone().startOf("month").toDate()

  finishDate: ->
    moment(@proejcts.lastDate()).clone().endOf("month")

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

  month: (start, end) =>
    # TODO Учитывать в ширине месяца колличество дней
    month: start.format 'MMMM'
    year:  start.format 'YYYY'
    width: @columnWidth() - 1 # 1 px на правую границу
    #width: end.diff(start, "days") * @columnWidth() - 1 # 1 px на правую границу

  index_of_current_month: ->
    moment().diff moment(@start), 'months'

  setColumnsWidth: ->
    # empty

  serializeData: ->
    months: @months()
    current_month: @index_of_current_month()
