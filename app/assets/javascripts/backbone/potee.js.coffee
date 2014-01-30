#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./mediators

window.Potee =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

window.App = window.Potee

Backbone.pEvent = _.extend({}, Backbone.Events)

@PoteeApp = do (Backbone, Marionette) ->

  App = new Marionette.Application

  isMobile = () ->
    userAgent = navigator.userAgent || navigator.vendor || window.opera
    return (/iPhone|iPod|iPad|Android|BlackBerry|Opera Mini|IEMobile/).test(userAgent)

  App.addRegions
    headerRegion: '#header'
    mainRegion:   '#main'

  App.addInitializer (options) ->
    window.router = new window.App.Routers.ProjectsRouter(options)

  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()

  App.mobile = isMobile()

  App
