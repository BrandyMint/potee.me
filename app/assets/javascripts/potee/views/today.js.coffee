# TODO Перевести на Marionette + Region
class Potee.Views.TodayView extends Backbone.View
  tagName: 'li'

  events:
    'click #today-link' : 'click'

  click: (e) ->
    # gotoToday переместить в модель
    PoteeApp.commands.execute 'gotoToday'

  render: ->
    if window.vc.todayIsPassed()
      title = '&larr; move to today'
    else
      title = 'move to today &rarr;'

    @$el.html "<a href='#today' id='today-link'>#{title}</a>"
    $('#today-nav').html @$el

    @
