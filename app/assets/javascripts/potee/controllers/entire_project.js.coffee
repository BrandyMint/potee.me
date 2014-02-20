class Potee.Controllers.EntireProject extends Marionette.Controller

  INDENTS: 200
  SPEED: 1000

  initialize: (options) ->
    { @scaller, @$viewport, @dashboard, @projects, @projects_view } = options

    @listenTo @dashboard, 'change:pixels_per_day', @_clear
    PoteeApp.seb.on 'project:current', @_clear
    #PoteeApp.vent.on 'project:click', @_clickProject
    PoteeApp.vent.on 'project:entire', @entireProject

    @_deaf = false

  entireProject: (project, options) =>
    # Сначала устнавливаем проект, потом entire
    PoteeApp.seb.fire 'project:current', project
    PoteeApp.seb.fire 'dashboard:mode', 'entire'
    @_scrollToProjectStart project.view, options

  #_clickProject: (project) =>
    #if project == PoteeApp.seb.get('project:current') && !PoteeApp.seb.get('dashboard:mode')
      #@entireProject project

  _clear: ->
    return if @_deaf
    console.log 'clear'
    PoteeApp.seb.fire 'dashboard:mode', null

  _scrollToProjectStart: (projectView, options={done: undefined}) ->
    projectDuration     = projectView.model.duration()
    finalProjectWidth   = @$viewport.width() - Math.max(@INDENTS, @dashboard.get('pixels_per_day')*2)

    date = projectView.model.middleMoment()
    scale = Math.round(finalProjectWidth / projectDuration)

    @_deaf = true

    PoteeApp.commands.execute 'gotoDate', date, done: =>
      @scaller.setScale scale
      # Если не влезает, при этом нужно отключать hover-ы
      #
      @projects_view.scrollToProjectView projectView
      @_deaf = false
      options.done?()
