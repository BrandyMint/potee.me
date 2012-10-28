Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.DaysView extends Backbone.View
  template: JST["backbone/templates/timelines/days"]

  tagName: 'div'
  className: 'days'

  initialize: (options) ->
    @start = moment(options.date_start, "YYYY-MM-DD")
    @end   = moment(options.date_finish, "YYYY-MM-DD")
    @range = moment().range(@start, @end)
    @column_width = options.column_width

  days: () ->
    days = []
    # iterate by 1 day
    today = moment().format('DDMMYYYY')
    @range.by "d", (m) ->
      day = 
        title: m.format('D')
        month: ''
        day: m.format('ddd')
        css_class: 'day'
      
      day['month'] = m.format('MMMM') if day['title'] == '1' || days.length == 0
      day['css_class'] += ' day_'+m.format('d')
      day['css_class'] += ' current' if m.format('DDMMYYYY') == today
      days.push day
    days

  set_column_width: () ->
    columnWidth = @column_width - 1 # 1px на правую границу
    @$el.find('table td').attr('width', columnWidth + "px")

  index_of_current_day: ->
    moment().diff(moment(@start), 'days') - 1

  render: =>
    $(@el).html(@template(days: @days(), current_day: @index_of_current_day()))
    @set_column_width()
    return this
