@Potee = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    navbarRegion: "#navbar-region"
  
  App.addInitializer ->
    App.module("NavbarApp").start()
  
  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()
  
  App

@Potee.Models =  {}
@Potee.Collections = {}
@Potee.Routers = {}
@Potee.Views = {}

Backbone.pEvent = _.extend({}, Backbone.Events);

window.start = (options)->
  window.router = new @Potee.Routers.ProjectsRouter(options)