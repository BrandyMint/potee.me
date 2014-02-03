class Potee.Controllers.EditMenu extends Marionette.Controller

  initialize: (options) ->
    { @projects_view } = options

    @editMenuRegion = new Backbone.Marionette.Region el: "#editmenu-region"
    @$navbarRegion = $(PoteeApp.navbarRegion.el)

    @projects_view.on 'project:selected', @_projectSelectedCallback
    @projects_view.on 'project:unselected', @_closeView

  _projectSelectedCallback: (project) =>
    editProjectView = new Potee.Views.EditMenu model: project
    @editMenuRegion.show editProjectView
    @$navbarRegion.hide()

  _closeView: =>
    @$navbarRegion.show()
    @editMenuRegion.close()
