class Potee.Controllers.TitleSticker
  constructor: (options)->
    @projects_view = options.projects_view
    Backbone.pEvent.on 'resetStickyTitles', @resetStickyTitles

  resetStickyTitles: () =>
    return false unless @projects_view.el
    # переменная @model в цикле не достпна
    dashboard = window.dashboard
    projects_top_point = @projects_view.$el.offset().top
    projects_bot_point = @projects_view.$el.height() + projects_top_point
    current_date = dashboard.getCurrentDate()
    window.projects.each (project, i) ->
      project_start_date = moment(project.get("started_at")).toDate()
      project_title_pos = project.view.titleView.sticky_pos
      project_top_point = project.view.titleView.$el.offset().top
      project_bot_point = project_top_point+project.view.titleView.$el.height() - 45
      valid_y_position = project_top_point > projects_top_point and project_bot_point < projects_bot_point

      if !dashboard.dateIsOnDashboard(project_start_date) and valid_y_position
        if current_date > project_start_date
          project.view.stickTitle('left')
        else
          project.view.stickTitle('right')
      else
        return if project_title_pos == undefined
        project.view.unstickTitle()
