class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = @getProjectsCollection(options.projects)
    window.projects = @projects

    @dashboard = new Potee.Models.Dashboard {}, {}, @projects
    @dashboard.fetch({async:false})
    window.dashboard = @dashboard

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
#    alert()
    window.dashboard.set 'scale', window.dashboard.calculateCurrentScaleByPixels()
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

  generateDashboardView: ->
    unless @dashboard_view
      @dashboard_view = new Potee.Views.DashboardView
        model: window.dashboard
      @dashboard_view.update()

    @dashboard_view.gotoCurrentDate()

  getProjectsCollection: (projects) ->
    collection = new Potee.Collections.ProjectsCollection()
    collection.reset(projects)
    collection
