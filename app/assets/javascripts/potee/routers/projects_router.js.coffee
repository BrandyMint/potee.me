class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    { @dashboard, @dashboard_view, @scaller } = options

  routes:
    ""              : "index"
    "index"         : "index"
    ".*"            : "index"
    "home"          : "home"
    "scale/:pixels" : "scale"
    "entire/:id"    : "entire"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"         : "index"

  home: ->
    console.log 'home'
    PoteeApp.seb.fire 'project:current', undefined
    @index()

  scale: (pixels) ->
    console.log 'SCALE'
    @scaller.setScale parseInt pixels
    @index()

  entire: (id) ->
    console.log "Displaying entire project with id = #{id}"
    @index()

    new Potee.Controllers.EntireProject
      project_id    : parseInt(id)
      $viewport     : window.viewport
      projects_view : window.projects_view
      dashboard     : window.dashboard
      projects      : window.projects
      scaller       : window.scaller

  index: ->
    @dashboard_view.show()