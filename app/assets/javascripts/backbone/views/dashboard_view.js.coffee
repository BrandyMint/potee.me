class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'
  #

  initialize: (options)->
    @viewport = $('#viewport')
    @model.view = @

    @currentForm = undefined
    @todayLink = undefined
    @programmedScrolling = false

    @projects_view = options.projects_view
    @timeline_view = options.timeline_view

    @viewport.bind 'scroll', @scroll

    $(document).bind 'click', @click

    $('#new-project-link').bind 'click', @newProject
    $('#dashboard').bind 'dblclick', @newProject_from_dbclick

    $('#dashboard').bind "pinch", (e, obj) =>
      @model.pinch obj.scale

    @listenTo @model, 'change:current_date', @resetTodayLink
    @listenTo @model, 'change:pixels_per_day', @updateScale

  updateScale: =>
    scale = @model.getTitle()

    @$el.removeClass("scale-week")
    @$el.removeClass("scale-month")
    @$el.removeClass("scale-year")

    @$el.addClass("scale-#{scale}")

    @resetWidth()
    # Нужно его обновлять именно следующим
    window.dashboard_view.timeline_view.render()

  click: (e) =>
    if @currentForm and $(e.target).closest(@currentForm.$el).length == 0
      @cancelCurrentForm()

  newProject_from_dbclick: (e)=>
    return if @currentForm
    # определяем вертикльную позицию клика относительно блока projects
    project_height = $('.project').height()
    topScroll = $('#projects').scrollTop()
    topOffset = $('#projects').offset().top
    topshift = e.pageY - topOffset + topScroll
    position = Math.round(topshift/project_height)

    # определяем дату по месту клика
    date = window.dashboard.datetimeAt(e.pageX - window.dashboard.view.$el.offset().left)
    @newProject(e, date, position)

  newProject: (e, startFrom = moment(), position = 0)=>
    e.stopPropagation()
    e.preventDefault()

    if window.dashboard.get('scale') == 'year'
      window.dashboard.set 'scale', 'month'

    $('#project_new').addClass('active')
    @projects_view.newProject startFrom, position
    return false

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
    if @viewportWidth() >= @$el.width()
      return true

    # TODO Тоже для правого края

    if @model.currentDate or @viewport.scrollLeft() > 1
      @$el.stop()
      date =  @model.dateOfMiddleOffset @viewport.scrollLeft()
      @model.setCurrentDate date

  #setPixelsPerDay: (pixels_per_day) ->
    #@model.set 'pixels_per_day', pixels_per_day
    #@setScale()
    #@gotoCurrentDate animate: false

  gotoToday: ->
    @model.setToday()
    @gotoDate @model.getCurrentDate()

  gotoCurrentDate: (options={animate:true}) ->
    @gotoDate @model.getCurrentDate(), options

  cancelCurrentForm: (e) =>
    @setCurrentForm undefined

  setCurrentForm: (form_view) =>
    if @currentForm
      @currentForm.close()
      @currentForm = undefined
    @currentForm = form_view

  # переустановить шируину дэшборда.
  resetWidth: ->
    @model.findStartEndDate()
    viewportWidth = @viewportWidth()
    if viewportWidth > @model.width()
      @model.setWidth(viewportWidth)
    @$el.css 'width', @model.width()

  viewportWidth: ->
    @viewport.width()

  render: ->
    @timeline_view.render()
    @projects_view.render()

    @resetWidth()
    @

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
