class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    @topPanelRegion = new Marionette.Region el: "#header_container"

    @projects_view.on 'project:selected', @_projectSelectedCallback
    @projects_view.on 'project:unselected', @_closeView

    @saved_dom = $('#header_container').clone()

  _projectSelectedCallback: (project) =>
    editProjectView = new Potee.Views.TopPanel.EditProject model: project
    @topPanelRegion.show editProjectView

  _closeView: =>

    @topPanelRegion.close()
    $('#header_container').empty()
    $('#header_container').append @saved_dom
