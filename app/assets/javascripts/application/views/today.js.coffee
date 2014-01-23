class Potee.Views.TodayView extends Backbone.View
  tagName: 'li'

  events:
    'click #today-link' : 'click'

  click: ->
    window.dashboard.view.gotoToday()

  render: ->
    if window.dashboard.todayIsPassed()
      title = '&larr; move to today'
    else
      title = 'move to today &rarr;'

    @$el.html "<a href='javascript:void()' id='today-link'>#{title}</a>"
    $('#today-nav').html @$el

    return this

