class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: ->
    @topPanelRegion = new Backbone.Marionette.Region el: "#toppanel-region"

    PoteeApp.vent.on 'edit:start', @editProject

  editProject: (project) =>
    editProjectView = new Potee.Views.TopPanel.EditProject model: project
    @topPanelRegion.show editProjectView
    
  close: ->
    @topPanelRegion.close()