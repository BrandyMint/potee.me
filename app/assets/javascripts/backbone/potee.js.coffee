#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./mediators

window.Potee =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  Controllers: {}
  Mediators: {}

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
    window.projects = new Potee.Collections.ProjectsCollection options.projects

    window.dashboard = new Potee.Models.Dashboard options.dashboard
    #dashboard.fetch async:false

    window.dashboard_view = new Potee.Views.DashboardView model: window.dashboard
    window.dashboard_view.render()

    window.router = new window.App.Routers.ProjectsRouter options

  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()

  App.mobile = isMobile()

  #Backbone.pEvent = App.vent

  App
