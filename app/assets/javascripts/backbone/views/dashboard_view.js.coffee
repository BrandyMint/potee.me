class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'
  #

  MAX_PIXELS_PER_DAY = 150
  MIN_PIXELS_PER_DAY = 4

  initialize: (options)->
    @setElement $('#dashboard')
    @viewport = $('#viewport')
    @model.view = @

    @currentForm = undefined
    @todayLink = undefined
    @programmedScrolling = false

    @timeline_view = new Potee.Views.TimelineView
      dashboard: @model
      dashboard_view: @

    @projects_view = new Potee.Views.Projects.IndexView
      projects: @model.projects

    new Potee.Controllers.DashboardPersistenter
    new Potee.Controllers.TitleSticker
      projects_view: @projects_view
    new Potee.Mediators.Keystrokes dashboard: @
    new Potee.Controllers.DragScroller
      $dashboard_el: @$el,
      viewport: @viewport,
      projects_view: @projects_view

    @viewport.bind 'scroll', @scroll

    $(document).bind 'click', @click

    $('#new-project-link').bind 'click', @newProject
    $('#dashboard').bind 'dblclick', @newProject_from_dbclick

    $('#dashboard').bind "pinch", (e, obj) =>
      @scalePixelsPerDay obj.scale

    $(window).resize =>
      @resetWidth()
      @timeline_view.render()

  click: (e) =>
    if @currentForm and $(e.target).closest(@currentForm.$el).length == 0
      @cancelCurrentForm()

  newProject_from_dbclick: (e)=>
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
    Backbone.pEvent.trigger 'resetStickyTitles'
    return false

  resetTodayLink: ->
    if @model.dateIsOnDashboard @model.today
      return unless @todayLink
      @todayLink.remove()
      @todayLink = undefined
    else
      return if @todayLink
      @todayLink = new Potee.Views.TodayView
      @todayLink.render()

  scroll: (e)=>
    Backbone.pEvent.trigger 'resetStickyTitles'
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

  incPixelsPerDay: ->
    @setPixelsPerDay @model.get('pixels_per_day')+5

  decPixelsPerDay: ->
    @setPixelsPerDay @model.get('pixels_per_day')-5

  scalePixelsPerDay: (scale) ->
    @setPixelsPerDay @model.get('pixels_per_day') * scale

  setPixelsPerDay: (pixels_per_day) ->
    pixels_per_day = @normalizedPixelsPerDay pixels_per_day
    scale = @getScaleForPixelsPerDay pixels_per_day
    @model.set "scale", scale if scale != @model.get("scale")
    @model.set 'pixels_per_day', pixels_per_day
    @setScale()
    @gotoCurrentDate(animate: false)

  normalizedPixelsPerDay: (pixels_per_day) ->
    Math.max Math.min(pixels_per_day, MAX_PIXELS_PER_DAY), MIN_PIXELS_PER_DAY

  getScaleForPixelsPerDay: (pixels_per_day)->
    if pixels_per_day > @model.MONTH_PIXELS_PER_DAY
      "week"
    else if pixels_per_day > @model.YEAR_PIXELS_PER_DAY
      "month"
    else
      "year"

  setScale: ->
    @timeline_view.resetScale()
    @resetWidth()

  gotoToday: ->
    @model.setToday()
    @gotoDate @model.getCurrentDate()

  gotoCurrentDate: (options={animate:true}) ->
    @gotoDate @model.getCurrentDate(), options

  cancelCurrentForm: (e) =>
    @setCurrentForm undefined

  setCurrentForm: (form_view) =>
    if @currentForm
      form = @currentForm
      @currentForm = undefined
      form.cancel()
    @currentForm = form_view

  # переустановить шируину дэшборда.
  resetWidth: ->
    @model.findStartEndDate()
    viewportWidth = @viewportWidth()
    if viewportWidth > @model.width()
      @model.setWidth(viewportWidth)
    @$el.css('width', @model.width())

  viewportWidth: ->
    @viewport.width()

  render: ->
    @$el.append @timeline_view.render().el
    @$el.append @projects_view.render().el

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
