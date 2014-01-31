class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
  routes:
    ""          : "index"
    "index"     : "index"
    'week'      : 'week'
    'month'     : 'month'
    'year'      : 'year'
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"       : "index"

  index: ->

  week: ->
    window.dashboard.setTitle 'week'

  month: ->
    window.dashboard.setTitle 'month'

  year: ->
    window.dashboard.setTitle 'year'
