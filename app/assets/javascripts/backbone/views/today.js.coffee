class Potee.Views.TodayView extends Backbone.View
  tagName: 'li'

  events:
    'click #today-link' : 'click'

  click: ->
    window.dashboard.view.gotoToday()

  render: ->
    @$el.html "<a href='javascript:void()' id='today-link'>move to today</a>"
    $('#today-nav').html @$el

    return this

