class Potee.Controllers.TodayLink
  constructor: (options) ->
    { @dashboard_view, @dashboard, @vc } = options

    @dashboard.on 'change:current_date', @resetTodayLink

    @todayLink = undefined
    #@resetTodayLink()

  resetTodayLink: =>
    return false unless @dashboard_view._shown
    if @vc.isDateOnViewport moment()
      return unless @todayLink
      @todayLink.remove()
      @todayLink = undefined
    else
      return if @todayLink
      @todayLink = new Potee.Views.TodayView
      @todayLink.render()

