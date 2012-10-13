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

window.start = (options)->
    window.dashboard = new App.Views.DashboardView(options.projects)
    $('#screen').append window.dashboard.el
    window.router = new App.Routers.ProjectsRouter(options)
    Backbone.history.start()
