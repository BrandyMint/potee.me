class Potee.Models.Project extends Backbone.Model
  paramRoot: 'project'

  initialize: ->
    #if !@get('color_index')
    #  @set 'color_index', (window.router.projects.size()+1) % 7
    @on 'change:color_index', @change_color
    @setStartEndDates()

    @calculateDays()

  events:
    "change:color_index" : "change_color"

  defaults:
    title: 'проект без названия'

  nextColor: ->
    @set 'color_index', ( @get('color_index') + 1 ) % 7
    @save()

  calculateDays: ->
    @firstDay = @get('color_index') # FIX window.dashboard.model.getIndexOfDay @get('started_at')
    @lastDay = @firstDay + 10 # window.dashboard.model.getIndexOfDay @get('finish_at') + 10 # FIX
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
