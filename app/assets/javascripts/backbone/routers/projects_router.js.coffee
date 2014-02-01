class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
  routes:
    ""          : "index"
    "index"     : "index"
    'days'      : 'days'
    'weeks'     : 'weeks'
    'months'    : 'months'
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"       : "index"

  index: ->

  days: ->
    window.dashboard.setTitle 'week'

  weeks: ->
    window.dashboard.setTitle 'month'

  months: ->
    window.dashboard.setTitle 'year'
