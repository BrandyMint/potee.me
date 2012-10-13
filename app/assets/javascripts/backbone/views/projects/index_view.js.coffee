Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: () ->
    @options.projects.bind('reset', @addAll)
    @render()

  addAll: () =>
    @options.projects.each(@addOne)

  addOne: (project) =>
    project.calculateDays()
    view = new Potee.Views.Projects.ProjectView
      model : project
    project.view = view
    @$el.append(view.render().el)

  render: =>
    # $(@el).html(@template(projects: @options.projects.toJSON() ))
    @addAll()
    $("#projects").html(@el)
    return this
