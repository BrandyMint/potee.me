class Potee.Routers.DashboardRouter extends Backbone.Router

  initialize: (options) ->
    { @dashboard, @dashboard_view } = options
  
  routes:
    "today": "moveToToday"

  moveToToday: ->
    @index()
    PoteeApp.commands.execute 'gotoToday'

  index: ->
    @dashboard_view.show()