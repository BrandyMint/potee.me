Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.DaysView extends Backbone.View
  template: JST["backbone/templates/timelines/days"]

  tagName: 'div'
  className: 'days'

  initialize: (options) ->
    start = moment(options.date_start, "YYYY-MM-DD")
    end   = moment(options.date_finish, "YYYY-MM-DD")
    @range = moment().range(start, end)
    @column_width = options.column_width

  days: () ->
    days = []
    # iterate by 1 day
    @range.by "d", (moment) ->
      days.push { title: moment.format("Do"), date: moment.format("YYYY-MM-DD")}
    days

  set_column_width: () ->
    columnWidth = @column_width - 1 # 1px на правую границу
    @$el.find('table td').attr('width', columnWidth + "px")

  render: =>
    $(@el).html(@template(days: @days()))
    @set_column_width()
    return this
