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

      projectDetailInfo.on 'project:submit', ->
        @model.set 'title', @ui.title.val()
        @model.save(null,
          success : (project) =>
            @model = project
            #window.dashboard.view.cancelCurrentForm()
            @model.view.setTitleView 'show'
            PoteeApp.seb.fire 'project:current', undefined
        )

      projectDetailInfo.on 'project:delete', ->
        if confirm("Sure to delete?")
          @model.destroy()
          PoteeApp.seb.fire 'project:current', undefined
    else
      @topPanelRegion.close()

      $('#header_container').empty()
      $('#header_container').append @saved_dom