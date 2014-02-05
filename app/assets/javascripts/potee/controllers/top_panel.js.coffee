class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    @topPanelRegion = new Marionette.Region el: "#header_container"
    @saved_dom = $('#header_container').children().clone()

    PoteeApp.seb.on 'project:current', @changeCurrentProject

  changeCurrentProject: (project) =>
    if project?
      projectDetailInfo = new Potee.Views.TopPanel.ProjectDetailView model: project
      @topPanelRegion.show projectDetailInfo
    else
      @topPanelRegion.close()

      $('#header_container').empty()
      $('#header_container').append @saved_dom
