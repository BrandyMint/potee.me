class Potee.Mediators.DashboardDater
  constructor: (options) ->
    @projects = options.projects
    @dashboard_info = options.dashboard_info

    Backbone.pEvent.on 'dashboard:stretch', @perform
    #Backbone.pEvent.on 'dashboard:reset_width', @perform

  # По списку проектов находит крайние левую и правые даты
  perform: =>
    #if @projects.length == 0
      #min = moment().startOf("day").toDate()
      #max = moment().add("months", 1).endOf("month").toDate()
    #else
      #min = @projects.first().started_at
      #max = @projects.first().finish_at

    #@projects.each (project)=>
        #if project.started_at < min
          #min = project.started_at

        #if project.finish_at > max
          #max = project.finish_at

    #window.dashboard.setMinMax min, max
