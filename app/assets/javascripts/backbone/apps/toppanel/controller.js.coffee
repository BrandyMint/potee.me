@PoteeApp.module "TopPanelApp", (TopPanelApp, App, Backbone, Marionette, $, _) ->

  class TopPanelApp.Controller extends Marionette.Controller

    initialize: (options) ->
      { project, event } = options

      if project
        @editView = @getEditProjectView model: project
      else if event
        @editView = @getEditEventView model: event
      else
        console.log 'В TopPanelApp переданы неверные аргументы'

      App.topPanelRegion.show @editView

    getEditProjectView: (project) ->
      new TopPanelApp.EditProjectView project

    getEditEventView: (event) ->
      new TopPanelApp.EditEventView event