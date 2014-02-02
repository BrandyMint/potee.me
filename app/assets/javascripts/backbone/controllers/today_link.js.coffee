class Potee.Controllers.TodayLink
  constructor: (options) ->
    @dashboard = options.dashboard
    @timeline  = options.timeline_view
    @dashboard.on 'change:current_date', @resetTodayLink

    @todayLink = undefined
    #@resetTodayLink()

  resetTodayLink: =>
    if @timeline.isDateOnDashboard @dashboard.today
      return unless @todayLink
      @todayLink.remove()
      @todayLink = undefined
    else
      return if @todayLink
      @todayLink = new Potee.Views.TodayView
      @todayLink.render()

