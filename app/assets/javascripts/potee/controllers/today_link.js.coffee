class Potee.Controllers.TodayLink
  constructor: (options) ->
    { @dashboard, @timeline } = options
    
    @dashboard.on 'change:current_date', @resetTodayLink

    @todayLink = undefined
    #@resetTodayLink()

  resetTodayLink: =>
    if @timeline.isDateOnDashboard moment()
      return unless @todayLink
      @todayLink.remove()
      @todayLink = undefined
    else
      return if @todayLink
      @todayLink = new Potee.Views.TodayView
      @todayLink.render()

