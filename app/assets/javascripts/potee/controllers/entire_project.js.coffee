class Potee.Controllers.EntireProject extends Marionette.Controller

  INDENTS: 50
  SPEED: 1000

  initialize: (options) ->
    { @scaller, @$viewport, @dashboard, @projects, @projects_view } = options

    @listenTo @dashboard, 'change:pixels_per_day', @_clear
    PoteeApp.seb.on 'project:current', @_clear
    PoteeApp.vent.on 'project:click', @_clickProject

  entireProject: (project, options) ->
    PoteeApp.seb.fire 'dashboard:mode', 'entire'
    PoteeApp.seb.fire 'project:current', project
    @_scrollToProjectStart project.view, options

  _clickProject: (project) =>
    if project == PoteeApp.seb.get('project:current') && !PoteeApp.seb.get('dashboard:mode')
      @entireProject project

  _clear: ->
    PoteeApp.seb.fire 'dashboard:mode', null

  _scrollToProjectStart: (projectView, options={done: undefined}) ->
    projectDuration     = projectView.model.duration()
    finalProjectWidth   = @$viewport.width() - @INDENTS * 2

    date = projectView.model.middleMoment()
    scale = Math.round(finalProjectWidth / projectDuration)

    PoteeApp.commands.execute 'gotoDate', date, done: =>
      @scaller.setScale scale
      # Если не влезает, при этом нужно отключать hover-ы
      #
      @projects_view.scrollToProjectView projectView
      options.done?()
