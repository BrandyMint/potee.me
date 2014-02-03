#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./controllers
#= require_tree ./observers
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
  Observers: {}

window.App = window.Potee

@PoteeApp = do (Backbone, Marionette) ->

  App = new Marionette.Application

  isMobile = () ->
    userAgent = navigator.userAgent || navigator.vendor || window.opera
    return (/iPhone|iPod|iPad|Android|BlackBerry|Opera Mini|IEMobile/).test(userAgent)

  App.addRegions
    headerRegion    : "#header"
    navbarRegion    : "#navbar-region"
    topPanelRegion  : "#toppanel-region"
    mainRegion      : "#main"
    timelineRegion  : "#timelint"
    projectsRegion  : "#projects"
    dashboardRegion : "#dashboard"

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

    # Инициализурется до projects_view
    new Potee.Controllers.GotoDate
      dashboard: window.dashboard
      $viewport: window.viewport

    window.timeline_view = new Potee.Views.TimelineView
      el: $('#timeline')
      $viewport: window.viewport
      dashboard: window.dashboard

    window.projects_view = new Potee.Views.Projects.IndexView
      el: $('#projects')
      dashboard: window.dashboard
      projects: window.projects
      timeline_view: window.timeline_view

    new Potee.Controllers.TitleSticker
      projects_view: window.projects_view

    new Potee.Controllers.DashboardPersistenter
      projects: window.projects
      projects_view: window.projects_view
      dashboard: window.dashboard

    new Potee.Controllers.NewProject
      projects_view: window.projects_view
      dashboard_view: window.dashboard_view

    new Potee.Controllers.EditFormPositioner

    new Potee.Controllers.DragScroller
      dashboard_el: $('#dashboard')
      viewport_el: window.viewport
      projects_view: window.projects_view

    new Potee.Controllers.TopPanel()

    window.dashboard_view = new Potee.Views.DashboardView
      el: $('#dashboard')
      model: window.dashboard
      $viewport    : window.viewport
      projects_view: window.projects_view
      timeline_view: window.timeline_view
      dashboard_info: window.dashboard_info

    window.hs = new Potee.Observers.HorizontalScroll
      $viewport: window.viewport
      dashboard: window.dashboard
      dashboard_view: window.dashboard_view

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
