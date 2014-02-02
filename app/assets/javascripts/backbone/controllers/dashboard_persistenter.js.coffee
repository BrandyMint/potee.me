class Potee.Controllers.DashboardPersistenter
  constructor: (options) ->
    @dashboard = options.dashboard
    @projects = options.projects
    @projects_view = options.projects_view

    Backbone.pEvent.on 'savePositions', @savePositions
    Backbone.pEvent.on 'projects:scroll', @updateScrollTop

    @timeout = undefined

    # TODO Сохранять с задержкой в 3 секунды
    @dashboard.on 'change', @saveDashboard

  updateScrollTop: =>
    @dashboard.set 'scroll_top', @projects_view.$el.scrollTop()

  saveDashboard: (dashboard) =>
    window.clearTimeout @timeout if @timeout?
    @timeout = window.setTimeout @_saveDashboard, 1000

  _saveDashboard: =>
      console.log 'saveDashboard'
      @dashboard.save {},
        silent: true  # Гасим звук, иначе она рассылает change и зацикливается
        parse: false  # Отключаем разбор данных с сервера, иначе у нас current_date будет постоянно скакать.
                      # Возможно от этого можно избавитья есл округлять current_date до минуты на сервере
                      # и на клиенте

  savePositions: () ->
    neworder = []
    $('#projects div.project').each () ->
      neworder.push $(this).attr("id")

    _.each neworder, (cid, i) ->
      project = @projects.get(cid)

      if project? && !project.isNew()
        project.set 'position', i
        project.save()
