class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = @getProjectsCollection(options.projects)
    window.projects = @projects

    @dashboard = new Potee.Models.Dashboard(@projects)

  routes:
    "new"      : "newProject"
    "index"    : "index"
    # ":id/edit" : "edit"
    # ":id"      : "show"
    ".*"        : "index"

  newProject: ->
    @dashboard_view ||= new Potee.Views.DashboardView(dashboard: @dashboard)
    # @view = new Potee.Views.Projects.NewView(collection: @projects)
    project = new Potee.Models.Project

    window.projects_view.addOne project, true
    project.view.setTitleView 'new'

  index: ->
    @dashboard_view = new Potee.Views.DashboardView(dashboard: @dashboard)


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
