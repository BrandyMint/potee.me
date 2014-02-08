#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./controllers
#= require_tree ./observers
#= require_tree ./views
#= require_tree ./regions
#= require_tree ./routers
#= require_tree ./mediators

@Potee =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  Controllers: {}
  Regions: {}
  Mediators: {}
  Observers: {}

@App = @Potee

@PoteeApp = do (Backbone, Marionette) ->
  App = new Marionette.Application

  isMobile = () ->
    userAgent = navigator.userAgent || navigator.vendor || window.opera
    return (/iPhone|iPod|iPad|Android|BlackBerry|Opera Mini|IEMobile/).test(userAgent)

  App.addRegions
    headerRegion    : "#header"
    navbarRegion    : "#navbar-region"
    mainRegion      : "#main"
    timelineRegion  : "#timelint"
    projectsRegion  : "#projects"
    dashboardRegion : "#dashboard"

  App.mobile = isMobile()

  Backbone.pEvent = App.vent
  App.seb = new A.StatedEventBroadcaster

  App.addInitializer (options) ->
    #window.projects_info = new Potee.Model.ProjectsInfo
    window.projects = new Potee.Collections.ProjectsCollection options.projects #, projects_info: window.projects_info

    window.viewport = $('#viewport')
    window.dashboard = new Potee.Models.Dashboard options.dashboard
    window.scaller = new Potee.Controllers.Scaller
      dashboard: window.dashboard

    # Инициализурется до projects_view
    new Potee.Controllers.GotoDate
      dashboard: window.dashboard
      $viewport: window.viewport

    window.timeline_view = new Potee.Views.TimelineView
      el: $('#timeline')
      $viewport: window.viewport
      dashboard: window.dashboard

    window.projects_view = new Potee.Views.Projects.IndexView
      el: $('#projects-index')
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

    new Potee.Controllers.HideInactiveProjects

    new Potee.Controllers.DragScroller
      dashboard_el: $('#dashboard')
      viewport_el: window.viewport
      projects_view: window.projects_view

    new Potee.Controllers.TopPanel
      projects_view: window.projects_view
      dashboard:     window.dashboard

    window.dashboard_view = new Potee.Views.DashboardView
      el: $('#dashboard')
      model:         window.dashboard
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

    window.current_form = new Potee.Controllers.CurrentForm

    new Potee.Controllers.SharedProject
      projects_view: window.projects_view

    new Potee.Controllers.ProjectSelector
      projects: window.projects

    new Potee.Controllers.ProjectsVisibility
      dashboard_view: window.dashboard_view

    window.nav = new Potee.Navigator
      dashboard: window.dashboard


    window.router = new Potee.Routers.ProjectsRouter
      scaller:        scaller
      dashboard:      window.dashboard
      dashboard_view: window.dashboard_view

  App.on "initialize:after", ->
    #Potee.history = new Potee.History
    Backbone.history.start()

  App.on "initialize:after", ->
    $(document).on 'click', '.j-link', (e) ->
      e.preventDefault()

      _.defer =>
        # Снимаем текущий проект хотябы тогда когда по логотипу ждем
        PoteeApp.seb.fire 'project:current', undefined
        Backbone.history.navigate $(@).attr('data-fragment'), trigger: true
      false

  App
