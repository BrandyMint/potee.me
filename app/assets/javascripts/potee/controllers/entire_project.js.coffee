class Potee.Controllers.EntireProject extends Marionette.Controller

  INDENTS: 50
  SPEED: 1000

  initialize: (options) ->
    { project_id, @scaller, @$viewport, @dashboard, @projects } = options

    project = @_getProjectByProjectId project_id
    if project?
      PoteeApp.seb.fire 'project:current', project
      @showEntireProject project, @INDENTS, @SPEED

  showEntireProject: (project, indents = 100, speed = 1000) =>
    @_scrollToProjectStart project.view, indents, speed

  _scrollToProjectStart: (projectView, indents, speed) ->
    # Первоначальное значение margin-left проекта, до изменения масштаба
    startProjectBar     = projectView.leftMargin() - indents
    projectDuration     = projectView.model.duration()
    initialProjectWidth = projectView.width()
    finalProjectWidth   = @$viewport.width() - indents * 2
    
    unless startProjectBar == @$viewport.scrollLeft()
      @scaller.setScale finalProjectWidth / projectDuration, changeUrl: false
      # Обновлённое значение отступа Проекта, после изменения масштаба
      startProjectBar = projectView.leftMargin() - indents

      @$viewport.animate 
        scrollLeft: startProjectBar, speed

  _getProjectByProjectId: (project_id) ->
    @projects.find (project) -> 
      return project.get('project_id') == project_id