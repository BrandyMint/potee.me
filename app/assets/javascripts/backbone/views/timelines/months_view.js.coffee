Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.MonthsView extends Potee.Views.Timelines.BaseView
  template: "templates/timelines/months"

  className: 'months'
  columnRate: 30

  startDate: ->
    moment(@projects.firstDate()).clone().startOf("month")

  finishDate: ->
    @_finishDate().add "months", @_extraMonths()

  _finishDate: ->
    moment(@projects.lastDate()).clone().endOf("month")

  columns_count: ->
    @months().length

  _extraMonths: ->
    offset = @offsetInPixels @_finishDate()
    extra_months_pixels = window.viewport.width() - offset

    # 50 дней сбоку
    minimal = @columnWidth() * 1.5
    extra_months_pixels = minimal if extra_months_pixels<minimal
    extra_month = Math.round extra_months_pixels/@columnWidth()
    extra_month = 1 if extra_month < 1

    extra_month

  # TODO cache
  months: () ->
    months = []

    months.push @month(@startDate(), @startDate().endOf('month'))

    range = moment().range @startDate(), @finishDate()
    # @finishDate().add("months", 1).startOf("month"),
    #                       @startDate().subtract("months", 1).endOf("month")

    range.by 'M', (m) =>
      start = m.clone().startOf('month')
      end = m.clone().endOf('month')

      # Алгорит range.by работает таким образом, что последнее переданное
      # значение может быть больше конца интервала, поэтому приходится это
      # проверять.
      if end < @finishDate()
        months.push @month(start, end)

    months.push @month(@finishDate().startOf('month'), @finishDate().add("days", 1))

    return months

  month: (start, end) =>
    # TODO Учитывать в ширине месяца колличество дней
    month: start.format 'MMMM'
    year:  start.format 'YYYY'
    width: @columnWidth() - 1 # 1 px на правую границу
    #width: end.diff(start, "days") * @columnWidth() - 1 # 1 px на правую границу

  index_of_current_month: ->
    moment().diff moment(@startDate), 'months'

    #setColumnsWidth: ->
    # empty

  serializeData: ->
    months: @months()
    current_month: @index_of_current_month()
