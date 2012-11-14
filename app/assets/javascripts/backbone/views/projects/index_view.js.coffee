Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: () ->
    @options.projects.bind('reset', @addAll)
    @render()
    Backbone.pEvent.on 'savePositions', this.savePositions
    Backbone.pEvent.on 'resetStickyTitles', this.resetStickyTitles
  
  addAll: =>
    @options.projects.each((project, i) => @addOne(project, false))

  insertToPosition: (project, position) =>
    view = new Potee.Views.Projects.ProjectView
      model : project
    current_project = $(".project:eq(" + position + ")")
    current_project.before(view.render().$el)
    view

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

  newProject: (startFrom = moment(), position = 0) ->
    project = new Potee.Models.Project({}, {}, startFrom)
    projects_count = window.projects.length

    if position > 0 and position < projects_count
      project_view = @insertToPosition project, position
    else
      project_view = @addOne project, (position < projects_count)
    project_view.setTitleView 'new'
    
  savePositions: () ->
    projects = window.projects
    neworder = []
    $('#projects div.project').each(() ->
      neworder.push $(this).attr("id")
    )

    _.each(neworder, (cid, i) ->
      project = projects.getByCid(cid)
      project.set('position', i)
      project.save()
    )

  resetStickyTitles: () ->
    # переменная @model в цикле не достпна
    dashboard = window.dashboard
    projects_top_point = $('#projects').offset().top
    projects_bot_point = $('#projects').height() + projects_top_point
    window.projects.each((project, i) ->
      project_start_date = moment(project.get("started_at")).toDate()
      project_title_pos = project.view.titleView.sticky_pos
      project_top_point = project.view.titleView.$el.offset().top
      project_bot_point = project_top_point+project.view.titleView.$el.height() - 45
      valid_y_position = project_top_point > projects_top_point and project_bot_point < projects_bot_point

      if !dashboard.dateIsOnDashboard(project_start_date) and valid_y_position
        if dashboard.currentDate > project_start_date
          project.view.stickTitle('left')
        else
          project.view.stickTitle('right')
      else
        return if project_title_pos == undefined
        project.view.unstickTitle()
    )