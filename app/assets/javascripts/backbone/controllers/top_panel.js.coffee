class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    @topPanelRegion = new Potee.Regions.SlideInSlideOutRegion el: "#toppanel-region"

    @projects_view.on 'project:selected', @_projectSelectedCallback
    @projects_view.on 'project:unselected', @_closeView

  _projectSelectedCallback: (project) =>
    editProjectView = new Potee.Views.TopPanel.EditProject model: project
    @topPanelRegion.show editProjectView

  _closeView: =>
    @topPanelRegion.close()
