class Potee.Controllers.HideInactiveProjects extends Marionette.Controller
  initialize: (options) ->
    PoteeApp.seb.on 'project:current', @changeCurrentProject

  changeCurrentProject: (current_project) =>
    window.projects.each (project) ->
      if project == current_project
        project.view.active()
      else
        project.view.inactive()
