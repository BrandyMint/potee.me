@PoteeApp.module "TopPanelApp", (TopPanelApp, App, Backbone, Marionette, $, _) ->

  API =
    show: (project) ->
      new TopPanelApp.Show.Controller model: project
    close: ->
      App.topPanelRegion.close()

  App.commands.setHandler "start:edit:project", (project) ->
    API.show project

  App.commands.setHandler "end:edit:project", (project) ->
    API.close()