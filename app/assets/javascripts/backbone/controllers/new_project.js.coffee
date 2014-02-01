class Potee.Controllers.NewProject
  constructor: (options) ->
    @projects_view = options.projects_view
    @dashboard_view = options.dashboard_view
    $('#new-project-link').bind 'click', @link
    $('#dashboard').bind 'dblclick', @dblclick

    PoteeApp.vent.on 'new_project', @_newProject

  dblclick: (e)=>
    return true if PoteeApp.reqres.request 'current_form:editing?'

    x = e.pageX - window.dashboard_view.left()

    # определяем дату по месту клика
    date = window.timeline_view.momentAt x

    @_newProject date, @_getClickPosition(e)

    return false

  # Вынести в роутер?
  link: (e) =>
    # TODO if window.dashboard.get('scale') == 'year'
      #window.dashboard.set 'scale', 'month'

    # TODO вынести в обсервер
    $('#project_new').addClass('active')
    @_newProject()
    return false

  _newProject: (startFrom = moment(), position = 0) =>
    project = new Potee.Models.Project {}, {}, startFrom
    projects_count = window.projects.length

    if position > 0 and position < projects_count
      project_view = @projects_view.insertToPosition project, position
    else
      project_view = @projects_view.addOne project, (position < projects_count)


  _getClickPosition: (e) ->
    # определяем вертикльную позицию клика относительно блока projects
    project_height = $('.project').height()
    topScroll = $('#projects').scrollTop()
    topOffset = $('#projects').offset().top
    topshift = e.pageY - topOffset + topScroll
    position = Math.round(topshift/project_height)


