class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @dashboard_view, @scaller } = options

  routes:
    ""          : "index"
    "index"     : "index"
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"       : "index"

    "scale/:pixels" : 'scale'

  scale: (pixels) ->
    @scaller.setScale parseInt pixels
    @index()

  index: ->
    @dashboard_view.show()

