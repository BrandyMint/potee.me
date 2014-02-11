class Potee.Controllers.ProjectSelector extends Marionette.Controller
  Z_INDEX_UNSELECTED: 100
  Z_INDEX_SELECTED: 150

  initialize: (options) ->
    { @projects } = options

    @listenTo PoteeApp.vent, 'escape',           @unselectProjectCallback

    @listenTo PoteeApp.seb, 'project:current', @changeCurrentProjectCallback

    @lastProject = undefined

  unselectProjectCallback: (project) =>
    if project? and PoteeApp.seb.get('project:current') != @lastSelectedProject
      console.log "!!! Отклоняемый проект не равент текущему"

    PoteeApp.seb.fire 'project:current', undefined

  changeCurrentProjectCallback: (project) =>
    # console.log 'change project', project
    @lastProject?.view.$el.css 'z-index', @Z_INDEX_UNSELECTED
    project?.view.$el.css 'z-index', @Z_INDEX_SELECTED

    @lastProject = project
