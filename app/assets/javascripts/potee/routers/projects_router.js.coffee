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
    @setScale 'week'

  weeks: ->
    @setScale 'month'

  months: ->
    @setScale 'year'

  setScale: (scale_name) ->
    return if scale_name == window.dashboard.getTitle()
    window.dashboard.setScale scale_name