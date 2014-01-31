@PoteeApp.module "TopPanelApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Controller extends Marionette.Controller
    
    initialize: (options = {}) ->
      @project = options.model
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @projectInfoRegion()

      App.topPanelRegion.show @layout
    
    projectInfoRegion: ->
      projectInfoView = @getProjectInfoView()
      @layout.projectInfoRegion.show projectInfoView

    getLayoutView: ->
      new Show.Layout()

    getProjectInfoView: () ->
      new Show.ProjectInfo model: @project