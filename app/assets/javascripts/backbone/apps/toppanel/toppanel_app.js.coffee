@PoteeApp.module "TopPanelApp", (TopPanelApp, App, Backbone, Marionette, $, _) ->

  API =
    editProject: (project) ->
      new TopPanelApp.Controller project: project
    editEvent: (event) ->
      new TopPanelApp.Controller event: event
    close: ->
      App.topPanelRegion.close()

  App.vent.on "project:edit:start", (project) ->
    API.editProject project

  App.vent.on "project:edit:end", (project) ->
    API.close()

  App.vent.on "event:edit:start", (event) ->
    API.editEvent event

  App.vent.on "event:edit:end", (project) ->
    API.close()

  App.vent.on "edit:end", (project) ->
    API.close()