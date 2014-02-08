class Potee.Controllers.NewProject
  constructor: (options) ->
    { @projects_view, @dashboard_view } = options
    @$projects = @projects_view.$el

    $(document).on 'click', '#new-project-link', @link
    $('#dashboard').bind 'dblclick', @dblclick

    PoteeApp.vent.on 'new_project', @_newProject

  dblclick: (e)=>
    # Идем дальше если кликнули на проекте
    #return false unless $(e.target).closest('.project .progress').length == 0
    return false unless $(e.target).closest('.project').length == 0

    return false if PoteeApp.request 'current_form:editing?'

    x = e.pageX - window.dashboard_view.left()

    # определяем дату по месту клика
    date = window.timeline_view.momentAt x
    position = @_getClickPosition(e)

    @_buildProject date, position

    return false

  # Вынести в роутер?
  link: (e) =>
    # TODO if window.dashboard.get('scale') == 'year'
      #window.dashboard.set 'scale', 'month'

    $('#project_new').addClass('active')

    @_newProject()

    return false

  _newProject: =>
    scrollTop = @$projects.scrollTop()
    if scrollTop > 100
      @$projects.animate scrollTop: 0, {
        easing: 'easeOutQuart'
        always: =>
          @_buildProject()
      }
    else
      @$projects.scrollTop 0 if scrollTop > 0
      @_buildProject()

  _buildProject: (startFrom = window.dashboard.getCurrentMoment(), position = 0) =>
      project = new Potee.Models.Project {}, {}, startFrom
      projects_count = window.projects.length

      if position > 0 and position < projects_count
        @projects_view.insertToPosition project, position
      else
        @projects_view.addOne project, (position < projects_count)


  _getClickPosition: (e) ->
    # определяем вертикльную позицию клика относительно блока projects
    project_height = $('.project').height()
    topScroll = @$projects.scrollTop()
    topOffset = @$projects.offset().top
    topshift = e.pageY - topOffset + topScroll

    return Math.round topshift/project_height
