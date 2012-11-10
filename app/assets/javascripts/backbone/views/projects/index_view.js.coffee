Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: () ->
    @options.projects.bind('reset', @addAll)
    @render()
  
  addAll: =>
    @options.projects.each((project, i) => @addOne(project, false))

  addOne: (project, prepend) =>
    view = new Potee.Views.Projects.ProjectView
      model : project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view

  render: ->
    @addAll()
    this.$el.sortable( 
      axis: "y",
      containment: "parent",
      distance: 20,
      opacity: 0.5,
      update: (event, ui) =>
        @savePositions()
      )
    this

  newProject: ->
    project = new Potee.Models.Project
    project_view = @addOne project, true
    project_view.setTitleView 'new'
    
  savePositions: () ->
    projects = window.projects
    neworder = []
    $('#projects div.project:visible').each(() ->
      neworder.push $(this).attr("id")
    )

    _.each(neworder, (cid, i) ->
      project = projects.getByCid(cid)
      project.set('position', i)
      project.save()
    )
