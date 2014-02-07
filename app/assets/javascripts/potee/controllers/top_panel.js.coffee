class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    el = '#header_container'
    # @topPanelRegion = new Marionette.Region el: el
    @saved_dom = $('#header_container').children()

    @$el = $ el

    @current_project = undefined

    PoteeApp.seb.on 'project:current', @changeCurrentProject
    PoteeApp.vent.on "project:create:start", @showNewProject

  changeCurrentProject: (project) =>
    return if @current_project?.model == project

    @current_project?.close()
    if project?
      projectDetailInfo = new Potee.Views.TopPanel.ProjectDetailView model: project
      @$el.html projectDetailInfo.render().$el.hide().fadeIn()
    else
      @restoreSavedDOM()

    @current_project = projectDetailInfo

  showNewProject: (project) =>
    @current_project?.close()
    newProjectView = new Potee.Views.TopPanel.NewProjectView model: project
    @$el.html newProjectView.render().$el.hide().fadeIn()

    newProjectView.on "project:create:cancel", @restoreSavedDOM

  restoreSavedDOM: =>
    $('#header_container').empty()
    $('#header_container').append @saved_dom.hide()
    setTimeout =>
      @saved_dom.fadeIn()