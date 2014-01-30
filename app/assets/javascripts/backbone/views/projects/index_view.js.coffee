Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: (@options) ->
    @selected_project_view = undefined
    @options.projects.bind 'reset', @addAll

  selectProjectView: (project_view) ->
    if @selected_project_view
      @selected_project_view.$el.css 'z-index', 100

    @selected_project_view = project_view
    @selected_project_view.$el.css 'z-index', 150

  buildProjectView: (project) ->
    view = new Potee.Views.Projects.ProjectView
      model : project
    @listenTo view, 'select', =>
      @selectProjectView view
    view

  addAll: =>
    @options.projects.each((project, i) => @addOne(project, false))

  insertToPosition: (project, position) =>
    view = @buildProjectView project
    current_project = $ ".project:eq(" + position + ")"
    current_project.before view.render().$el
    view

  addOne: (project, prepend) =>
    view = @buildProjectView project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view

  resetScale: ->
    @options.projects.each (project) =>
      project.view.setDuration()

  render: ->
    @addAll()
    @$el.sortable
      axis: "y",
      containment: "parent",
      distance: 20,
      opacity: 0.5,
      update: (event, ui) =>
        Backbone.pEvent.trigger 'savePositions'

    # Корректируем sticky titles при вертикальном скроллинге
    @$el.bind 'scroll', =>
      Backbone.pEvent.trigger 'resetStickyTitles'

    @

  newProject: (startFrom = moment(), position = 0) ->
    project = new Potee.Models.Project({}, {}, startFrom)
    projects_count = window.projects.length

    if position > 0 and position < projects_count
      project_view = @insertToPosition project, position
    else
      project_view = @addOne project, (position < projects_count)
    project_view.setTitleView 'new'

