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

@PoteeApp = do (Backbone, Marionette) ->

  App = new Marionette.Application

  isMobile = () ->
    userAgent = navigator.userAgent || navigator.vendor || window.opera
    return (/iPhone|iPod|iPad|Android|BlackBerry|Opera Mini|IEMobile/).test(userAgent)

  App.addRegions
    headerRegion: '#header'
    mainRegion:   '#main'
    timelineRegion: '#timelint'
    projectsRegion: '#projects'
    dashboardRegion: '#dashboard'

  App.mobile = isMobile()

  Backbone.pEvent = App.vent

  App.addInitializer (options) ->
    #window.projects_info = new Potee.Model.ProjectsInfo
    window.projects = new Potee.Collections.ProjectsCollection options.projects #, projects_info: window.projects_info

    window.viewport = $('#viewport')
    window.dashboard = new Potee.Models.Dashboard
    window.scale_panel = new Potee.Controllers.ScalePanel dashboard: window.dashboard
    window.di = window.dashboard_info = new Potee.Models.DashboardInfo

    # Нужно устанавливать данные после ScalePanel, чтобы она поставила правильное обозначение масштаба
    window.dashboard.set options.dashboard

    new Potee.Controllers.DashboardPersistenter projects: window.projects

    new Potee.Mediators.DashboardDater
      projects: window.projects
      dashboard_info: window.dashboard_info

    window.timeline_view = new Potee.Views.TimelineView
      el: $('#timeline')
      dashboard: window.dashboard

    window.projects_view = new Potee.Views.Projects.IndexView
      el: $('#projects')

    new Potee.Controllers.TitleSticker projects_view: window.projects_view

    new Potee.Controllers.NewProject
      projects_view: window.projects_view
      dashboard_view: window.dashboard_view

    new Potee.Controllers.DragScroller
      dashboard_el: $('#dashboard')
      viewport_el: $('#viewport')
      projects_view: window.projects_view

    window.dashboard_view = new Potee.Views.DashboardView
      el: $('#dashboard')
      model: window.dashboard
      projects_view: window.projects_view
      timeline_view: window.timeline_view
      dashboard_info: window.dashboard_info

    new Potee.Mediators.Keystrokes
      dashboard_view: window.dashboard_view
      dashboard: window.dashboard

    new Potee.Controllers.CurrentForm

    window.dashboard_view.render()

    $(window).resize =>
      window.dashboard_view.resetWidth()
      window.timeline_view.render()

    window.router = new window.App.Routers.ProjectsRouter options

  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()

  App
