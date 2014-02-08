class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view, @dashboard } = options

    sp = new Potee.Views.ScalePanel
    sp.render()

    el = '#header_container'
    # @topPanelRegion = new Marionette.Region el: el
    @saved_dom = $('#header_container').children().clone true

    @$el = $ el

    @current_project = undefined

    @listenTo @dashboard, 'change:pixels_per_day', @closePanel

    PoteeApp.seb.on 'project:current', @changeCurrentProject

  closePanel: =>
    PoteeApp.seb.fire 'project:current', undefined

  changeCurrentProject: (project) =>
    return if @current_project?.model == project

    @current_project?.close()
    if project?
      projectDetailInfo = new Potee.Views.TopPanel.ProjectDetailView model: project
      @$el.html projectDetailInfo.render().$el.hide()
      projectDetailInfo.$el.fadeIn()
    else
      @closePanel()

    @current_project = projectDetailInfo
