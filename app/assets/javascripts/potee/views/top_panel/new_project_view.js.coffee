Potee.Views.TopPanel = {}

class Potee.Views.TopPanel.NewProjectView extends Marionette.ItemView
  template: "templates/top_panel/new_project_view"
  id: "toppanel"

  modelEvents:
    "destroy": ->
      @trigger "project:create:cancel"