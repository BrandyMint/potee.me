class Potee.Controllers.ProjectsVisibility extends Marionette.Controller
  initialize: (options) ->
    { @dashboard_view } = options

    PoteeApp.vent.on 'projects:scroll', @showOrHideProjects

    @lastScrollTop = 0

  showOrHideProjects: (e) =>
    PoteeApp.seb.fire 'project:current', undefined

    scrollTop = $(e.target).scrollTop()
    return if scrollTop == @lastScrollTop

    _.defer =>
      # поползли вверх
      if scrollTop > @lastScrollTop
        window.projects.each (project) ->
          project.view.correctOpacity
            moving: 'up'
      # Поползли вниз
      else
        window.projects.each (project) ->
          project.view.correctOpacity
            moving: 'down'

      @lastScrollTop = scrollTop
