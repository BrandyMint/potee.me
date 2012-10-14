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
    title: 'Your project name'

  nextColor: ->
    @set 'color_index', ( @get('color_index') + 1 ) % 7
    @save()

  toJSON: ->
    res = super(this)
    res['cid'] = @cid

    return res

  change_color: (model, olor_index)->
#    @calculateDays()
    if @view
      @view.render()
      @view.bounce()
    # @view.$el.find('.progress').addClass('active')

  setStartEndDates: ->
    @started_at = moment(@get("started_at")).toDate()
    @finish_at = moment(@get("finish_at")).toDate()

  duration: ->
    return moment(@finish_at).diff(moment(@started_at), "days") + 1

  # duration - количество дней
  setDuration: (duration) ->
    finishAt = moment(@started_at).clone().add("days", duration)

    @set("finish_at", finishAt.format("YYYY-MM-DD"))
    @save()
    @setStartEndDates()

    return

class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'

  initialize: ->
    @on 'remove', (project) ->
      project.destroy()

  # Ищем следующий свободный цвет
  getNextColorIndex: ->
    @length != 0 ? (@last().get('color_index')+1) % 7 : 1

    # TODO
    #colors = {}
    #@map (el) ->
      #colors[el.get('color_index')]||=0
      #colors[el.get('color_index')]+=1


    # (window.router.projects.size()+1) % 7
