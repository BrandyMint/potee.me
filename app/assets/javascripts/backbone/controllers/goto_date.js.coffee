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
  moveToDate: (date = undefined, animate = true) =>
    x = @timeline().middleOffsetOf date || @dashboard.today

    if @$viewport.scrollLeft() == x
      @dashboard.setCurrentDate date
      return

    window.hs.activateIntentionalScrolling()

    if animate
      # TODO Посылать скроллинг в cпециальную очередь?
      @$viewport.stop().animate { scrollLeft: x }, 
        duration: 500,
        easing: 'easeInOutExpo',
        always: =>
          @_scrollingDone date

        #      setTimeout (=>@programmedScrolling = false), 1200 # оказалось, что это надёжнее callback'a выше
        #setTimeout (=>@resetTodayLink()), 1000
    else
      @$viewport.scrollLeft x
      @_scrollingDone date

  _scrollingDone: (date)=>
    @dashboard.setCurrentDate date
    window.hs.deactivateIntentionalScrolling()
