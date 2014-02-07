class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    el = '#header_container'
    # @topPanelRegion = new Marionette.Region el: el
    @saved_dom = $('#header_container').children().clone()

    @$el = $ el

    @current_project = undefined

    PoteeApp.seb.on 'project:current', @changeCurrentProject

  changeCurrentProject: (project) =>
    return if @current_project?.project == project

    @current_project?.close()
    if project?
      projectDetailInfo = new Potee.Views.TopPanel.ProjectDetailView model: project
      @$el.html projectDetailInfo.render().$el.hide()
      projectDetailInfo.$el.fadeIn()
    else

      $('#header_container').empty()
      $('#header_container').append @saved_dom.hide()
      @saved_dom.fadeIn()

    @current_project = projectDetailInfo
