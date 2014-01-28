#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Potee =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

window.App = window.Potee

Backbone.pEvent = _.extend({}, Backbone.Events);

@PoteeApp = do (Backbone, Marionette) ->

  App = new Marionette.Application
  
  App.addInitializer (options) ->
    window.router = new window.App.Routers.ProjectsRouter(options)

  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()
  
  App