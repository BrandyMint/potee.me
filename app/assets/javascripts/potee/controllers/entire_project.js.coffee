class Potee.Controllers.EntireProject extends Marionette.Controller

  initialize: (options) ->
    { @scaller, @$viewport, @projects_view, @dashboard, @projects } = options

    PoteeApp.vent.on "project:current:focus", @showEntireProject

  showEntireProject: (@project, indents = 100, speed = 1000) =>
    $project_view = project.view.$el
    @_scrollToProjectStart $project_view, indents, speed

  _scrollToProjectStart: (projectView, indents, speed) ->
    # Первоначальное значение отступа Проекта, до изменения масштаба
    startProjectBar = parseInt( projectView.css("margin-left") ) - indents
    projectStartDate = moment(@project.get("started_at"))
    projectEndDate = moment(@project.get("finish_at"))
    projectDuration = projectEndDate.diff(projectStartDate, 'days') + 1

    initialProjectWidth = projectView.width()
    finalProjectWidth = @$viewport.width() - indents * 2

    # centerOfViewport = startProjectBar + projectView.width() - @$viewport.width() / 2
    # if initialProjectWidth < @dashboard.get('pixels_per_day') * 6
    #   @$viewport.animate 
    #     scrollLeft: centerOfViewport, speed
    
    unless startProjectBar is @$viewport.scrollLeft()
      @scaller.setScale finalProjectWidth / projectDuration
      # Обновлённое значение отступа Проекта, после изменения масштаба
      startProjectBar = parseInt( projectView.css("margin-left") ) - indents

      @$viewport.animate 
        scrollLeft: startProjectBar, speed