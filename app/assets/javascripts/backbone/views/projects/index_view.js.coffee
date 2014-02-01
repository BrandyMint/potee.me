Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  initialize: ->
    @selected_project_view = undefined

    @projects = window.projects
    @projects.bind 'reset', @addAll
    @listenTo window.dashboard, 'change:pixels_per_day', @resetScale
    PoteeApp.vent.on 'timeline:stretched', @resetWidth
  # переустановить шируину дэшборда.
  #
  resetWidth: =>
    #Backbone.pEvent.trigger 'dashboard:reset_width'
    @$el.css 'width', window.timeline_view.width()


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
    @projects.each((project, i) => @addOne(project, false))

  insertToPosition: (project, position) =>
    view = @buildProjectView project
    current_project = $ ".project:eq(" + position + ")"
    current_project.before view.render().$el
    view.bounce() if view.isNew()
    Backbone.pEvent.trigger 'projects:reorder'
    view

  addOne: (project, prepend) =>
    view = @buildProjectView project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view.bounce() if view.isNew()
    view

  resetScale: =>
    @projects.each (project) =>
      project.view.resetScale()

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
      Backbone.pEvent.trigger 'projects:scroll'

    @

