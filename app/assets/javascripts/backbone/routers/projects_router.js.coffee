class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = @getProjectsCollection(options.projects)
    window.projects = @projects

    @dashboard = new Potee.Models.Dashboard @projects

    window.dashboard = @dashboard

  routes:
    "new"      : "newProject"
    "index"    : "index"
    # ":id/edit" : "edit"
    # ":id"      : "show"
    ".*"        : "index"
    'week'      : 'scaleToWeek'
    'month'     : 'scaleToMonth'
    'year'      : 'scaleToYear'

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
    @dashboard_view ||= new Potee.Views.DashboardView
      model: @dashboard
    @dashboard_view.gotoCurrentDate()

  newProject: ->
    @generateDashboardView()
    $('#project_new').addClass('active')
    # @view = new Potee.Views.Projects.NewView(collection: @projects)
    project = new Potee.Models.Project

    window.projects_view.addOne project, true
    project.view.setTitleView 'new'

  index: ->
    @generateDashboardView()

  #show: (id) ->
    #project = @projects.get(id)

  #edit: (id) ->
    #project = @projects.get(id)

    #project.view.setTitleView('edit')

    # @project_title_view = new Potee.Views.Projects.EditView(model: project)
    # project.view.title_view
    # $("#").html(@view.render().el)

  getProjectsCollection: (projects) ->
    collection = new Potee.Collections.ProjectsCollection()
    collection.reset(projects)
    return collection
