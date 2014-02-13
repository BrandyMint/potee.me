class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @dashboard_view, @scaller, @entire } = options

  routes:
    ""              : "index"
    "index"         : "index"
    ".*"            : "index"
    "home"          : "home"
    "entire/:id"    : "entire"

  home: ->
    console.log 'home'
    PoteeApp.seb.fire 'project:current', undefined
    @index()
    PoteeApp.commands.execute 'gotoToday'

  entire: (id) ->
    console.log "Displaying entire project with id = #{id}"
    @index()
    #project_id = parseInt id

    #@entire.
    #PoteeApp.seb.fire 'project:current', undefined


    #project = @projects.getByProjectId project_id
    #if project?
      #@entireProject project

  index: ->
    @dashboard_view.show()
