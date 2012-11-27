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

window.start = (options)->
    window.router = new App.Routers.ProjectsRouter(options)
    Backbone.history.start()
