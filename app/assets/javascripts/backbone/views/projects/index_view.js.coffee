Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: () ->
    @options.projects.bind('reset', @addAll)
    @render()

  addAll: =>
    @options.projects.each(@addOne)

  addOne: (project, prepend) =>
    view = new Potee.Views.Projects.ProjectView
      model : project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view.$el.find('div.bar').droppable(
      drop: (e, ui) =>
        event = ui.draggable
        own_project_id = event.data('project_id')
        @changeProject(event.data('id'), project, own_project_id) if own_project_id != project.id
    ) 
    view

  render: ->
    @addAll()
    this

  newProject: ->
    project = new Potee.Models.Project
    project_view = @addOne project, true
    project_view.setTitleView 'new'

  changeProject: (event_id, project, own_project_id) ->
    collection = new Potee.Collections.ProjectsCollection
    collection.fetch()
    own_project = collection.get(own_project_id)
    event = own_project.projectEvents.get(event_id)
    event.setProject(project)

