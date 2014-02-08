class Potee.Controllers.SharedProject extends Marionette.Controller
  initialize: (options) ->
    { @projects_view } = options
    PoteeApp.commands.setHandler 'add_shared_project', (project) =>
      project.id = undefined
      project.title = "(shared)" + project.title

      project = new Potee.Models.Project project

      @projects_view.scrollTopAndCallback =>
        @projects_view.addOne project, true
        @projects_view.scrollToMoment project.started_at
