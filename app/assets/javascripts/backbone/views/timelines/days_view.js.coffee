Potee.Views.Timelines ||= {}

class Potee.Views.Timelines.DaysView extends Potee.Views.Timelines.BaseView
  template: "templates/timelines/days"

  className: 'days'
  columnRate: 1
  spanDays: 5


  #@days = moment(max).diff(moment(min), "days") + 1

  offsetInPixels: (day) ->
    #day * @get('pixels_per_day')
    throw "Откуда взялась такая дата? #{day}" unless _.isObject(day)

    minutes = moment(day).diff @startDate(), 'minutes'
    (window.dashboard.get('pixels_per_day') * minutes) / (24*60)

  startDate: ->
    moment(@projects.firstDate()).clone().subtract('days', @spanDays).toDate()

  finishDate: ->
    moment(@projects.lastDate()).clone().add('days', @spanDays).toDate()

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

  index_of_current_day: ->
    moment().diff(moment(@start), 'days') - 1

  serializeData: ->
    days: @days()
    current_day: @index_of_current_day()
