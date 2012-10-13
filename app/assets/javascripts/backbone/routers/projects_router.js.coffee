class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = new Potee.Collections.ProjectsCollection()
    @projects.reset options.projects

  routes:
    "new"      : "newProject"
    "index"    : "index"
    # ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newProject: ->
    @view = new Potee.Views.Projects.NewView(collection: @projects)
    $("#projects").html(@view.render().el)

  index: ->
    @view = new Potee.Views.Projects.IndexView(projects: @projects)
    $("#projects").html(@view.render().el)

  show: (id) ->
    project = @projects.get(id)

    @view = new Potee.Views.Projects.ShowView(model: project)
    $("#projects").html(@view.render().el)

  edit: (id) ->
    project = @projects.get(id)

    project.view.setTitleView('edit')

    # @project_title_view = new Potee.Views.Projects.EditView(model: project)
    # project.view.title_view
    # $("#").html(@view.render().el)
