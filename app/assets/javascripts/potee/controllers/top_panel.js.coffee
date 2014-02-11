class Potee.Controllers.TopPanel extends Marionette.Controller

  initialize: (options) ->
    { @projects_view, @dashboard } = options

    @$el = $ '#header_container'

    @current_view = undefined

    @main_header = new Potee.Views.MainHeader

    @current_view = @main_header
    @showCurrent()

    PoteeApp.seb.on 'project:current', @changeCurrentProject

  changeCurrentProject: (project) =>
    return if @current_view?.model == project

    @current_view?.close()

    if project?
      @current_view = new Potee.Views.TopPanel.ProjectDetailView model: project
    else
      @current_view = @main_header

    @showCurrent()

  showCurrent: ->
    @$el.html @current_view.render().$el.hide()
    @current_view.$el.fadeIn()
