class Potee.Models.Project extends Backbone.Model
  paramRoot: 'project'

  initialize: ->

    # TODO Передавать номер дня на котором кликнули создание проекта
    # от него и начинать
    @initNew() if @isNew()

    @setStartEndDates()

    @on 'change:color_index', @change_color

    @initProjectEventsCollection()

  initNew: ->
    @set 'color_index', window.projects.getNextColorIndex() if !@has('color_index')
    @set 'events', [] if !@has('events')

    today = new Date()

    @set 'started_at', today.toString() if !@has('started_at')
    @set 'finish_at', moment(today).add('days',7).toString() if !@has('finish_at')

  initProjectEventsCollection: ->
    # Свойство events используется для событий Backbone модели, поэтому
    # использовать его для обозначения списка событий не получается.
    @projectEvents = new Potee.Collections.EventsCollection(project: this)
    @projectEvents.reset(@get("events"))

    @unset 'events',
      silent: true

  events:
    "change:color_index" : "change_color"
  defaults:
    title: 'без названия'
    color_index: 1

  nextColor: ->
    @set 'color_index', ( @get('color_index') + 1 ) % 7
    @save()

  # Этот метод может быть вызыван только в том случае, если
  # window.router.dashboard уже инициализирован, поэтому его
  # невозможно вызывать в конструкторе, так как проекты
  # инициализируются раньше window.dashboard.
  calculateDays: ->
    @firstDay = window.router.dashboard.indexOf(@started_at, "days")
    @lastDay = window.router.dashboard.indexOf(@finish_at, "days") + 1 # Прибавляем еще один день, чтобы проект заканчивался в конце дня
    @firstWeek = window.router.dashboard.indexOf(@started_at, "weeks")
    @lastWeek = window.router.dashboard.indexOf(@finish_at, "weeks")
    @firstMonth = window.router.dashboard.indexOf(@started_at, "months")
    @lastMonth = window.router.dashboard.indexOf(@finish_at, "months")

    @duration_in_days = @lastDay - @firstDay
    @duration_in_weeks = @lastWeek - @firstWeek
    @duration_in_months = @lastMonth - @firstMonth

  progressDiv: ->

  toJSON: ->
    res = super(this)
    res['cid'] = @cid

    return res

  change_color: (model, olor_index)->
    @calculateDays()
    if @view
      @view.render()
      @view.bounce()
    # @view.$el.find('.progress').addClass('active')

  setStartEndDates: ->
    @started_at = moment(@get("started_at")).toDate()
    @finish_at = moment(@get("finish_at")).toDate()

  days_to_scale: (scale) ->
    switch scale
      when "days"
        1
      when "weeks"
        7
      when "months"
        # считаем количество дней в месяце
        m = moment(@started_at).clone().startOf('month')
        next_month = m.clone().add('months', 1)
        next_month.diff(m, 'days')

  first_item_by_scale: (scale) ->
    switch scale
      when "days"
        @firstDay
      when "weeks"
        @firstWeek
      when "months"
        @firstMonth

  duration_by_scale: (scale) ->
    switch scale
      when "days"
        @duration_in_days
      when "weeks"
        @duration_in_weeks
      when "months"
        @duration_in_months

class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'

  initialize: ->
    @on 'remove', (project) ->
      project.destroy()

  # Ищем следующий свободный цвет
  getNextColorIndex: ->
    (@last().get('color_index')+1) % 7

    # TODO
    #colors = {}
    #@map (el) ->
      #colors[el.get('color_index')]||=0
      #colors[el.get('color_index')]+=1


    # (window.router.projects.size()+1) % 7
