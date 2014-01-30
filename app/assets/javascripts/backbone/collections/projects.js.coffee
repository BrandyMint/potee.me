class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'

  initialize: ->
    @on 'remove', (project) ->
      project.destroy()
      
    this.comparator = (project) ->
      project.get("position")

  # Ищем следующий свободный цвет
  getNextColorIndex: ->
    return 0 if @length == 0
    (@last().get('color_index')+1) % 7
