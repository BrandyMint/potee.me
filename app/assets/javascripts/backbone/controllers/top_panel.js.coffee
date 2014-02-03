class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    @$buttons = $('.buttons-nav')
    @topPanelRegion = new Backbone.Marionette.Region el: "#toppanel-region"

    @projects_view.on 'project:selected', @_projectSelectedCallback
    @projects_view.on 'project:unselected', @_closeView

  _projectSelectedCallback: (project) =>
    editProjectView = new Potee.Views.TopPanel.EditProject model: project
    @topPanelRegion.show editProjectView
    @$buttons.hide()

  _closeView: =>
    @topPanelRegion.close()
    @$buttons.show()