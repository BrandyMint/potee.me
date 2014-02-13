class Potee.Controllers.GotoDate
  constructor: (options)->
    { @dashboard, @$viewport } = options

    PoteeApp.commands.setHandler 'gotoDate', @moveToDate
    PoteeApp.commands.setHandler 'gotoToday', @moveToDate

    #@dashboard.on 'change:current_date', =>
      #@moveToDate @dashboard.getCurrentDate()

  # Контроллер создается раньше чем timeline_view
  timeline: ->
    window.timeline_view

  # Перейти на указанную дату (отцентировать).
  # @param [Date] date
  # - undefined - today
  moveToDate: (date = undefined, options = {animate: true, duration: 500, done: undefined }) =>
    x = @timeline().middleOffsetOf date || moment()

    if @$viewport.scrollLeft() == x
      @dashboard.setCurrentDate date
      options.done?()
      return

    window.hs.activateIntentionalScrolling()

    if options.animate
      # TODO Посылать скроллинг в cпециальную очередь?
      @$viewport.stop().animate { scrollLeft: x }, 
        duration: options.duration,
        easing: 'easeInOutExpo',
        always: =>
          @_scrollingDone date
          options.done?()

        #      setTimeout (=>@programmedScrolling = false), 1200 # оказалось, что это надёжнее callback'a выше
        #setTimeout (=>@resetTodayLink()), 1000
    else
      @$viewport.scrollLeft x
      @_scrollingDone date
      options.done?()

  _scrollingDone: (date)=>
    @dashboard.setCurrentDate date
    window.hs.deactivateIntentionalScrolling()
