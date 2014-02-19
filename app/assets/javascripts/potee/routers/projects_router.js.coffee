class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @projects, @dashboard_view, @scaller, @entire } = options

  routes:
    ""              : "index"
    "index"         : "index"
    "home"          : "home"
    "entire/:project_id" : "entire"
    "today"         : "today"
    "scale/:pixels" : "scale"
    ".*"            : "index"

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

  today: ->
    @index()
    PoteeApp.commands.execute 'gotoToday'

  scale: (pixels) ->
    # Делаем silent: true иначе при первое рендере страницы
    # с изменением масштаба проекты не отображаются (хотя в доме есть)
    @scaller.setScale pixels, silent: true
    @index()

  index: ->
    @dashboard_view.show()
