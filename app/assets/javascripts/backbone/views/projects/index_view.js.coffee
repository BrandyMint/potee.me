Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: (@options) ->
    @options.projects.bind 'reset', @addAll

  addAll: =>
    @options.projects.each((project, i) => @addOne(project, false))

  insertToPosition: (project, position) =>
    view = new Potee.Views.Projects.ProjectView
      model : project
    current_project = $(".project:eq(" + position + ")")
    current_project.before(view.render().$el)
    view

  addOne: (project, prepend) =>
    view = new Potee.Views.Projects.ProjectView
      model : project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view

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

    this

  newProject: (startFrom = moment(), position = 0) ->
    project = new Potee.Models.Project({}, {}, startFrom)
    projects_count = window.projects.length

    if position > 0 and position < projects_count
      project_view = @insertToPosition project, position
    else
      project_view = @addOne project, (position < projects_count)
    project_view.setTitleView 'new'

