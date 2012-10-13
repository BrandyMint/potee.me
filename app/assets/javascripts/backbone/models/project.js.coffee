class Potee.Models.Project extends Backbone.Model
  paramRoot: 'project'

  initialize: ->
    @on 'change:color_index', @change_color

    @firstDay = @get('color_index') # FIX window.dashboard.model.getIndexOfDay @get('started_at')
    @lastDay = @firstDay + 10 # window.dashboard.model.getIndexOfDay @get('finish_at') + 10 # FIX
    @duration = @lastDay - @firstDay + 1

  events:
    "change:color_index" : "change_color"

  defaults:
    title: 'проект без названия'

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
