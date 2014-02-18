#
# https://github.com/BrandyMint/Potee/issues/198
#
class Potee.Controllers.ProjectCentrizer extends Marionette.Controller
  initialize: (options) ->
    { @$viewport, @dashboard, @projects_view, @timeline_view } = options

    @listenTo PoteeApp.seb, 'project:current', @currentProject

  currentProject: (project) =>
    return unless project?
    return if project.isMomentIn @dashboard.getCurrentMoment()

    days_on_viewport = @$viewport.width() / @dashboard.get('pixels_per_day')

    if days_on_viewport >= project.duration()
      PoteeApp.commands.execute 'gotoDate', project.middleMoment()
    # Проект не целиком на рабочем столе
    else
      current =  @dashboard.getCurrentMoment()
      # текущая дата = конец проекта - 3/4 от половины экрана
      diff_days = days_on_viewport*3/8 - 1

      # | | | + | | |
      # -----------
      #
      # проект сильно слева
      if project.finish_at < current.subtract('days',2)
        date = moment(project.finish_at).subtract 'days', diff_days
        PoteeApp.commands.execute 'gotoDate', date

      # проект сильно слева
      else if project.started_at > current.add('days',2)
        date = moment(project.started_at).add 'days', diff_days + 2
        PoteeApp.commands.execute 'gotoDate', date
      else
        console.log "!!! Невозможное размещение проекта", project, current
      @

