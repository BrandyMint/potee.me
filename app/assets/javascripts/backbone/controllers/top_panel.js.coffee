class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    @topPanelRegion = new Backbone.Marionette.Region el: "#toppanel-region"

    @projects_view.on 'project:selected', @_projectSelectedCallback
    @projects_view.on 'project:unselected', @_closeView

  _projectSelectedCallback: (project) ->
    editProjectView = new Potee.Views.TopPanel.EditProject model: project
    @topPanelRegion.show editProjectView

  _closeView: ->
    @topPanelRegion.topPanelRegion.close()
