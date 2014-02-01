@PoteeApp.module "TopPanelApp", (TopPanelApp, App, Backbone, Marionette, $, _) ->

  class TopPanelApp.EditProjectView extends Marionette.ItemView
    template: "apps/toppanel/templates/edit_project"

  class TopPanelApp.EditEventView extends Marionette.ItemView
    template: "apps/toppanel/templates/edit_event"
      