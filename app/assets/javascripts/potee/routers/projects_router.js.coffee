class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @dashboard_view } = options

  routes:
    ""          : "index"
    "index"     : "index"
    'days'      : 'days'
    'weeks'     : 'weeks'
    'months'    : 'months'
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"       : "index"

    "scale/:pixels" : 'scale'

  scale: (pixels) ->
    @dashboard.set 'pixels_per_day', parseInt(pixels)
    @dashboard_view.show()

  index: ->
    window.dashboard_view.show()

  days: ->
    @setScale 'week'

  weeks: ->
    @setScale 'month'

  months: ->
    @setScale 'year'

  setScale: (scale_name) ->
    @dashboard.setScale scale_name
    @dashboard_view.show()
