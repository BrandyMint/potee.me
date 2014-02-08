class Potee.Controllers.ProjectsVisibility extends Marionette.Controller
  initialize: (options) ->
    { @projects_view, @$viewport } = options

    PoteeApp.vent.on 'projects:scroll', @showOrHideProjects

    @lastScrollTop = 0

  showOrHideProjects: (e) =>
    PoteeApp.seb.fire 'project:current', undefined

    scrollTop = $(e.target).scrollTop()
    height = $(e.target).height()

    project_height = 30
    max_top = height - project_height - 40

    return if scrollTop == @lastScrollTop


    # поползли вверх
    if scrollTop > @lastScrollTop
      window.projects.each (project) ->
        _.defer ->
          top = project.view.$el.position().top
          if top >= max_top
            x = 35 - (top - max_top)
            x = 0 if x < 0
            project.view.setOpacity x/35
          else if top > 35 && top < max_top
            project.view.setOpacity 1
          else if top < 3 || top > max_top
            project.view.setOpacity 0
          else if top < 35
            project.view.setOpacity top/35

    # Поползли вниз
    else
      window.projects.each (project) ->
        _.defer ->
          top = project.view.$el.position().top
          if top >= max_top
            x = 35 - (top - max_top)
            x = 0 if x < 0
            project.view.setOpacity x/35
          else if top > max_top + 35
            project.view.setOpacity 0
          else if top > 35
            project.view.setOpacity 1
          else
            project.view.setOpacity top/35

    @lastScrollTop = scrollTop
