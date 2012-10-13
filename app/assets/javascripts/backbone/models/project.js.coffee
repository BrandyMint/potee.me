class Potee.Models.Project extends Backbone.Model
  paramRoot: 'project'

  initialize: ->
    #if !@get('color_index')
    #  @set 'color_index', (window.router.projects.size()+1) % 7
    @on 'change:color_index', @change_color
    @setStartEndDates()

    # Свойство events используется для событий Backbone модели, поэтому
    # использовать его для обозначения списка событий не получается.
    @projectEvents = new Potee.Collections.EventsCollection(project: this)
    @projectEvents.reset(@get("events"))

  events:
    "change:color_index" : "change_color"

  defaults:
    title: 'проект без названия'

  nextColor: ->
    @set 'color_index', ( @get('color_index') + 1 ) % 7
    @save()

  # Этот метод может быть вызыван только в том случае, если
  # window.router.dashboard уже инициализирован, поэтому его
  # невозможно вызывать в конструкторе, так как проекты
  # инициализируются раньше window.dashboard.
  calculateDays: ->
    @firstDay = window.router.dashboard.indexOf(@started_at)
    @lastDay = window.router.dashboard.indexOf(@finish_at)

    @duration = @lastDay - @firstDay + 1

  progressDiv: ->

  change_color: (model, olor_index)->
    @calculateDays()
    if @view
      @view.render()
      @view.bounce()
    # @view.$el.find('.progress').addClass('active')

  setStartEndDates: ->
    @started_at = moment(@get("started_at")).toDate()
    @finish_at = moment(@get("finish_at")).toDate()

class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'
