@PoteeApp.module "TopPanelApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Layout extends Marionette.Layout
    template: "apps/toppanel/show/templates/layout"
    className: "navbar-inner"

    regions:
      projectInfoRegion: "#projectinfo-region"

  class Show.ProjectInfo extends Marionette.ItemView
    template: "apps/toppanel/show/templates/_projectinfo"