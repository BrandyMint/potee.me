class Potee.Controllers.DashboardPersistenter
  constructor: (options) ->
    { @dashboard, @projects, @projects_view } = options

    Backbone.pEvent.on 'savePositions', @savePositions
    Backbone.pEvent.on 'projects:scroll', @updateScrollTop

    $( window ).on 'beforeunload', =>
      @_clearTimeout()
      @_saveDashboard()
      return undefined

    @_timeout = undefined

    @dashboard.on 'change', @saveDashboard

  updateScrollTop: =>
    @dashboard.set 'scroll_top', @projects_view.$el.scrollTop()

  _clearTimeout: =>
    window.clearTimeout @_timeout if @_timeout?

  saveDashboard: (dashboard) =>
    @_clearTimeout()
    @_timeout = window.setTimeout @_saveDashboard, 1000

  _saveDashboard: =>
    console.log 'saveDashboard'
    @dashboard.save {},
      silent: true  # Гасим звук, иначе она рассылает change и зацикливается
      parse: false  # Отключаем разбор данных с сервера, иначе у нас current_date будет постоянно скакать.
                    # Возможно от этого можно избавитья есл округлять current_date до минуты на сервере
                    # и на клиенте

  savePositions: () ->
    neworder = []
    window.projects_view.$el.find('.project').each () ->
      neworder.push $(@).attr("id")

    _.each neworder, (cid, i) ->
      project = @projects.get(cid)

      if project? && !project.isNew()
        project.set 'position', i
        project.save()
