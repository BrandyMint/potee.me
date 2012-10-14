class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = @getProjectsCollection(options.projects)
    window.projects = @projects

    @dashboard = new Potee.Models.Dashboard(@projects)

    window.dashboard = @dashboard

  routes:
    "new"      : "newProject"
    "index"    : "index"
    # ":id/edit" : "edit"
    # ":id"      : "show"
    ".*"        : "index"
    'days'      : 'scaleToDays'
    'weeks'     : 'scaleToWeeks'
    'months'    : 'scaleToMonths'

  scaleToWeeks: ->
    @generateDashboardView()
    window.dashboard.set 'scale', 'weeks'

  scaleToMonths: ->
    @generateDashboardView()
    window.dashboard.set 'scale', 'months'

  scaleToDays: ->
    @generateDashboardView()
    window.dashboard.set 'scale', 'days'

  generateDashboardView: ->
    @dashboard_view ||= new Potee.Views.DashboardView
      model: @dashboard

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
