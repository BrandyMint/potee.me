Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: () ->
    @options.projects.bind('reset', @addAll)
    window.projects_view = this
    @render()

  addAll: () =>
    @options.projects.each(@addOne)

  addOne: (project, prepend) =>
    project.calculateDays()
    view = new Potee.Views.Projects.ProjectView
      model : project
    project.view = view

    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el

  render: =>
    # $(@el).html(@template(projects: @options.projects.toJSON() ))
    @addAll()

    # $("#projects").html(@el)
    return this
