class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @dashboard_view, @scaller } = options

  routes:
    ""          : "index"
    "index"     : "index"
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"     : "index"
    "home"      : "home"

    "scale/:pixels" : 'scale'

  home: ->
    console.log 'home'
    PoteeApp.seb.fire 'project:current', undefined
    @index()

  scale: (pixels) ->
    console.log 'SCALE'
    @scaller.setScale parseInt pixels
    @index()

  index: ->
    @dashboard_view.show()

