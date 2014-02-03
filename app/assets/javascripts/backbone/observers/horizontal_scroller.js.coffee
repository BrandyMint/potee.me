class Potee.Observers.HorizontalScroll
  constructor: (options) ->
    { @$viewport, @dashboard, @dashboard_view } = options
    @timeline = window.timeline_view

    @_unbindes = 0
    @bindScrollingCallback()

    @intentionalScrolling = false

  intentionalScroll: (offset) =>
    @unbindScrollingCallback()
    @$viewport.scrollLeft offset

    # Байндим через некоторое время, потому что иначе байнд
    # успевает привязаться до того, как скроллинг закончен
    setTimeout @bindScrollingCallback, 100

  bindScrollingCallback: =>
    console.log 'bind horizontal scrolling'
    @$viewport.bind 'scroll', @scrollCallback if ++@_unbindes==1

  unbindScrollingCallback: =>
    console.log 'unbind horizontal scrolling'
    @$viewport.unbind 'scroll', @scrollCallback if --@_unbindes==0

  deactivateIntentionalScrolling: ->
    console.log 'deactivate intentional scrolling'
    @intentionalScrolling = false

  activateIntentionalScrolling: ->
    console.log 'activate intentional scrolling'
    @intentionalScrolling = true

  scrollCallback: (e)=>
    # Ловит TitleSticker
    Backbone.pEvent.trigger 'dashboard:scroll'

    return false if @intentionalScrolling
    #console.log 'scroll callback'

    # Если мы сменили масштаб где физиески нельзя поставить сегодняшнюю дату
    # 
    #if @viewport.width() >= @$el.width()
      #return true

    # TODO Тоже для правого края
    #if @viewport.scrollLeft() > 1
    #
    @dashboard_view.$el.stop() # Прекращаем все анимации

    @dashboard.setCurrentDate @timeline.momentOfTheMiddle()
