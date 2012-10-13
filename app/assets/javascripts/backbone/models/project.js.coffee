class Potee.Models.Project extends Backbone.Model
  paramRoot: 'project'

  initialize: ->
    @on 'change:color_index', @change_color

  events:
    "change:color_index" : "change_color"

  defaults:
    title: 'проект без названия'

  firstDayIndex: ->
    window.dashboard.getDaysIndex @get('started_at')

  lastDay: ->
    window.dashboard.getDaysIndex @get('finish_at') + 10 # FIX

  nextColor: ->
    @set 'color_index', ( @get('color_index') + 1 ) % 7
    @save()

  progressDiv: ->

  change_color: (model, olor_index)->
    @view.render()
    @view.bounce()
    # @view.$el.find('.progress').addClass('active')

class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'
