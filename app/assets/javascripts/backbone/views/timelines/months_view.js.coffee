Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.MonthsView extends Backbone.View
  template: JST["backbone/templates/timelines/months"]

  tagName: 'div'
  className: 'months'

  initialize: (options) ->
    start = moment(options.date_start, "YYYY-MM-DD")
    end   = moment(options.date_finish, "YYYY-MM-DD")
    @range = moment().range(start.startOf('month'), end.endOf('month'))
    @column_width = options.column_width

  months: () ->
    months = []
    # iterate by 1 month
    @range.by "M", (moment) ->
      months.push(moment.format("MMMM, YYYY"))
    months

  set_column_width: () ->
    days_in_months = []
    @range.by "M", (moment) ->
      next_month = moment.clone().add('months', 1)
      count = next_month.diff(moment, 'days')
      days_in_months.push(count)

    column_width = @column_width
    @$el.find('table td').each (index) ->
      $(this).attr('width', column_width * days_in_months[index] + "px")

  render: =>
    $(@el).html(@template(months: @months()))
    @set_column_width()
    return this