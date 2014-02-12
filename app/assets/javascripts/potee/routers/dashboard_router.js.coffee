class Potee.Routers.DashboardRouter extends Backbone.Router

  initialize: (options) ->
    { @dashboard, @dashboard_view, @scaller } = options
  
  routes:
    "today"         : "moveToToday"
    "scale/:pixels" : "scale"

  moveToToday: ->
    @index()
    PoteeApp.commands.execute 'gotoToday'

  scale: (pixels) ->
    console.log 'SCALE'
    @scaller.setScale parseInt pixels
    @index()

  index: ->
    @dashboard_view.show()