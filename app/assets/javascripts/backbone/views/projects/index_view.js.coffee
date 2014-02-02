Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  initialize: (options)->

    @timeline = options.timeline_view
    @projects = options.projects
    @dashboard = options.dashboard

    @selected_project_view = undefined
    @projects.bind 'reset', @addAll

    @listenTo @dashboard, 'change:pixels_per_day', @resetScale
    PoteeApp.vent.on 'timeline:stretched', @resetWidth

  # переустановить шируину дэшборда.
  resetWidth: =>
    @$el.css 'width', @timeline.width()

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
    some_project = $ ".project:eq(" + position + ")"
    some_project.before view.render().$el
    view.bounce() if view.isNew()
    Backbone.pEvent.trigger 'project:rendered', view
    Backbone.pEvent.trigger 'projects:reorder'
    view

  addOne: (project, prepend) =>
    view = @buildProjectView project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view.bounce() if view.isNew()
    Backbone.pEvent.trigger 'project:rendered', view
    view

  resetScale: =>
    @projects.each (project) =>
      project.view.resetScale()

  render: ->
    @addAll()
    @scrollToCurrentDate()
    @scrollToLastScrollTop()

    # Перемещаемся на текущее место
    #PoteeApp.commands.setHandler 'gotoCurrentDate'
    @$el.sortable
      axis: "y",
      containment: "parent",
      distance: 20,
      opacity: 0.5,
      update: (event, ui) =>
        Backbone.pEvent.trigger 'savePositions'

    # Корректируем sticky titles при вертикальном скроллинге
    # TODO Пусть sticky titles сами вешаются на on 'render' списка проектов
    @$el.bind 'scroll', =>
      Backbone.pEvent.trigger 'projects:scroll'

    @

  scrollToLastScrollTop: ->
    console.log "scroll top", @dashboard.get('scroll_top')
    @$el.scrollTop @dashboard.get('scroll_top')

  scrollToCurrentDate: ->
    # Отключаем автоматическое обновление даты по скроллингу

    window.hs.intentionalScroll @timeline.middleOffsetOf window.dashboard.getCurrentDate()
