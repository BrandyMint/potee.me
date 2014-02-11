class Potee.Controllers.TitleSticker
  constructor: (options)->
    @projects_view = options.projects_view
    @timeline_view = window.timeline_view
    @dashboard = window.dashboard
    Backbone.pEvent.on 'dashboard:scroll', @resetStickyTitles
    Backbone.pEvent.on 'projects:scroll', @resetStickyTitles
    Backbone.pEvent.on 'projects:reorder', @resetStickyTitles
    PoteeApp.on 'projects:reset_scale', => _.defer @resetStickyTitles

    #PoteeApp.seb.on 'timeline:scale_mode', @resetStickyTitles

    @$projects = $ '#projects'

  resetStickyTitles: () =>
    return false unless @projects_view.el
    console.log 'reset sticky titles'

    # переменная @model в цикле не достпна
    projects_top_point = @$projects.offset().top
    projects_bot_point = @$projects.height() + projects_top_point
    current_date = @dashboard.getCurrentDate()

    window.projects.each (project, i) ->
      return unless project.view?.titleView?
      console.log 'reset sticky titles', i
      project_start_date = project.started_at
      project_title_pos = project.view.titleView.sticky_pos

      # Используем координаты проекта вместо title
      # потому что иначе при пеерключении из week в day
      # левые titles сразу не показываются
      # project_top_point = project.view.titleView.$el.offset().top
      #
      project_top_point = project.view.$el.offset().top
      project_bot_point = project_top_point+project.view.titleView.$el.height() - 45

      # По высоте проект вообще виден?
      valid_y_position = project_top_point > projects_top_point and project_bot_point < projects_bot_point

      if !@timeline_view.isDateOnDashboard(project.started_at) and valid_y_position
        console.log 'reset sticky titles 2', i
        if project.started_at < current_date
          project.view.stickTitle 'left'
        else
          project.view.stickTitle 'right'
      else
        return if project_title_pos == undefined
        project.view.unstickTitle()
