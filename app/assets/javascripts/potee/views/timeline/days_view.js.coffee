Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.DaysView extends Potee.Views.Timelines.BaseView
  template: "templates/timelines/days"

  className: 'days'
  columnRate: 1
  spanDays: 5

  startDate: ->
    @_startDate().subtract 'days', @columnsOnTheScreenCount()/2

  _startDate: ->
    moment(@projects.firstDate()).clone().subtract('days', @spanDays)

  finishDate: ->
    @_finishDate().add 'days', @columnsOnTheScreenCount()/2 #@_extraColumns()

  _finishDate: ->
    moment(@projects.lastDate()).clone().add('days', @spanDays)


  columns_count: ->
    #@days = moment(max).diff(moment(min), "days") + 1
    @days().length

  days: ->
    days = []
    # iterate by 1 day
    today = moment().format('DDMMYYYY')
    @dateRange().by "d", (m) ->
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

  index_of_current_column: ->
    moment().diff(moment(@start), 'days') - 1

  serializeData: ->
    days: @days()
    current_day: @index_of_current_column()
