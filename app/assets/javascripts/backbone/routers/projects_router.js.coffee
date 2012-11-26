class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = @getProjectsCollection(options.projects)
    window.projects = @projects
    window.dashboard = @createDashboard()

  routes:
    ""          : "index"
    "index"     : "index"
    'week'      : 'scaleToWeek'
    'month'     : 'scaleToMonth'
    'year'      : 'scaleToYear'
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"       : "index"

  index: ->
    window.dashboard.pixels_per_day = window.dashboard.get('pixel_scale')
    @generateDashboardView()

  scaleToWeek: ->
    window.dashboard.set 'scale', 'week'
    @generateDashboardView()

  scaleToMonth: ->
    window.dashboard.set 'scale', 'month'
    @generateDashboardView()

  scaleToYear: ->
    window.dashboard.set 'scale', 'year'
    @generateDashboardView()
  
  createDashboard: ->
    dashboard = new Potee.Models.Dashboard {}, {}, @projects
    dashboard.fetch({async:false})
    dashboard

  generateDashboardView: ->
    @dashboard_view ||= new Potee.Views.DashboardView
      model: window.dashboard
    @dashboard_view.gotoCurrentDate()

  getProjectsCollection: (projects) ->
    collection = new Potee.Collections.ProjectsCollection()
    collection.reset(projects)
    collection
