class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'
  #

  initialize: (options)->
    @viewport = $('#viewport')
    @model.view = @

    @todayLink = undefined
    @programmedScrolling = false

    @projects_view = options.projects_view
    @timeline_view = options.timeline_view
    @dashboard_info = options.dashboard_info

    @viewport.bind 'scroll', @scroll

    $('#dashboard').bind "pinch", (e, obj) =>
      @model.pinch obj.scale

    @listenTo @model, 'change:current_date', @resetTodayLink
    @listenTo @model, 'change:pixels_per_day', @updateScale

    # Устанавливаем ширину dashboard-а на основании ширины timeline, как только она изменилась
    PoteeApp.vent.on 'timeline:stretched', @resetWidth

  updateScale: =>
    scale = @model.getTitle()

    @$el.removeClass("scale-week")
    @$el.removeClass("scale-month")
    @$el.removeClass("scale-year")

    @$el.addClass("scale-#{scale}")

    #@resetWidth()
    # Нужно его обновлять именно следующим
    #window.dashboard_view.timeline_view.render()

  resetTodayLink: =>
    if @model.dateIsOnDashboard @model.today
      return unless @todayLink
      @todayLink.remove()
      @todayLink = undefined
    else
      return if @todayLink
      @todayLink = new Potee.Views.TodayView
      @todayLink.render()

  scroll: (e)=>
    Backbone.pEvent.trigger 'dashboard:scroll'
    if @programmedScrolling
      return false

    # Если мы сменили масштаб где физиески нельзя поставить сегодняшнюю дату
    # 
    if @viewport.width() >= @$el.width()
      return true

    # TODO Тоже для правого края

    if @model.currentDate or @viewport.scrollLeft() > 1
      @$el.stop()
      date =  @model.dateOfMiddleOffset @viewport.scrollLeft()
      @model.setCurrentDate date

  gotoToday: ->
    @model.setToday()
    @gotoDate @model.getCurrentDate()

  gotoCurrentDate: (options={animate:true}) ->
    @gotoDate @model.getCurrentDate(), options

  # переустановить шируину дэшборда.
  resetWidth: =>
    #Backbone.pEvent.trigger 'dashboard:reset_width'
    @$el.css 'width', @viewport.width()

    #viewportWidth = @viewport.width()
    #if viewportWidth > @model.width()
      #@model.setWidth viewportWidth
    #@$el.css 'width', @model.width()

  render: ->
    @timeline_view.render()
    @projects_view.render()

    @resetWidth()
    @

  left: ->
    @$el.offset().left

  # Перейти на указанную дату (отцентировать).
  # @param [Date] date
  gotoDate: (date, options = {animate: true}) ->
    x = @model.middleOffsetOf date
    return if @viewport.scrollLeft() == x
    @programmedScrolling = true
    @model.setCurrentDate(date)
    if  options.animate
      @viewport.stop().animate { scrollLeft: x }, 1000, 'easeInOutExpo' #, => @programmedScrolling = false
      setTimeout (=>@programmedScrolling = false), 1200 # оказалось, что это надёжнее callback'a выше
      setTimeout (=>@resetTodayLink()), 1000
    else
      @viewport.scrollLeft x
      @programmedScrolling = false
      @resetTodayLink()
