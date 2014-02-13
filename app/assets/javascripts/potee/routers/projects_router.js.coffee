class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @projects, @dashboard_view, @scaller, @entire } = options

  routes:
    ""              : "index"
    "index"         : "index"
    ".*"            : "index"
    "home"          : "home"
    "entire/:project_id" : "entire"

  home: ->
    console.log 'home'
    PoteeApp.seb.fire 'project:current', undefined
    @index()
    PoteeApp.commands.execute 'gotoToday'

  entire: (project_id) ->
    console.log "Displaying entire project with id = #{project_id}"
    project = @projects.getByProjectId parseInt(project_id)

    if project?
      unless @dashboard_view._shown
        # Ставим заранее дату, чтобы dashboard не дергался
        @dashboard.setCurrentDate project.middleMoment()
        @dashboard_view.show()

      @entire.entireProject project
    else
      @index()
      window.alert "No such project #{project_id}"

  index: ->
    @dashboard_view.show()
