class Potee.Controllers.ProjectsVisibility extends Marionette.Controller
  initialize: (options) ->
    { @projects_view } = options

    PoteeApp.vent.on 'projects:scroll', @showOrHideProjects

    @lastScrollTop = 0

  showOrHideProjects: (e) =>
    scrollTop = $(e.target).scrollTop()
    height = $(e.target).height()

    project_height = 30
    max_top = height - project_height - 40

    return if scrollTop == @lastScrollTop


    # поползли вверх
    if scrollTop > @lastScrollTop
      console.log 'вверх'

      window.projects.each (project) ->
        top = project.view.$el.position().top
        if top > 35 && top < max_top
          project.view.$el.stop().css opacity: 1
        else if top < 3 || top > max_top
          project.view.$el.stop().css opacity: 0
        else if top < 35
          project.view.$el.stop().css opacity: top/35
        else if top >= max_top-35
          x = 35 - (top - max_top)
          x = 0 if x < 0
          project.view.$el.stop().css opacity: x/35


    # Поползли вниз
    else
      window.projects.each (project) ->
        top = project.view.$el.position().top
        if top >= max_top
          x = 35 - (top - max_top)
          x = 0 if x < 0
          project.view.$el.stop().css opacity: x/35
        else if top > max_top + 35
          project.view.$el.stop().css opacity: 0
        else if top > 35
          project.view.$el.stop().css opacity: 1
        else
          project.view.$el.stop().css opacity: top/35


    @lastScrollTop = scrollTop
