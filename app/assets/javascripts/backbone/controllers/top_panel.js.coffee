class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: ->
    PoteeApp.vent.on 'edit:start', @editProject

  editProject: (project) ->
    editProjectView = new Potee.Views.TopPanel.EditProject model: project
    PoteeApp.topPanelRegion.show editProjectView
  close: ->
    PoteeApp.topPanelRegion.close()