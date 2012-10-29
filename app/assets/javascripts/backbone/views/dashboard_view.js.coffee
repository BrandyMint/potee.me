class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'
  #

  MAX_PIXELS_PER_DAY = 150
  MIN_PIXELS_PER_DAY = 4

  initialize: (options)->
    @viewport = $('#viewport')
    @model.view = this
    @setElement($('#dashboard'))
    @update()

    @programmedScrolling = false

    @viewport.bind('scroll', @scroll)
    $(document).bind('keydown', @keydown)
    $(document).bind('click', @click)
    $('#new-project-link').bind('click', @newProject)
    $('#projects').dblclick(@newProject)

    $(window).resize =>
      @resetWidth()
      @timeline_view.render()

    @allowScrollByDrag()

    @currentForm = undefined
    @todayLink = undefined

  click: (e) =>
    if @currentForm and $(e.target).closest(@currentForm.$el).length == 0
      @cancelCurrentForm()

  newProject: (e)=>
    e.stopPropagation()
    e.preventDefault()

    $('#project_new').addClass('active')

    @projects_view.newProject()
    return false

  resetTodayLink: (date)->
    if @model.dateIsOnDashboard @model.today
      return unless @todayLink
      @todayLink.remove()
      @todayLink = undefined
    else
      return if @todayLink
      @todayLink = new Potee.Views.TodayView
      @todayLink.render()

  scroll: (e)=>
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

  Keys =
    Enter: 13
    Escape: 27
    Space: 32
    Plus: 187
    Minus: 189

  keydown: (e) =>
    e ||= window.event
    switch e.keyCode
      when Keys.Escape
        # отмена формы
        e.preventDefault()
        e.stopPropagation()
        @cancelCurrentForm(e)
      when Keys.Enter
        # новый проект
        @newProject(e) unless @currentForm
      when Keys.Space
        # перейти на сегодня
        unless @currentForm
          e.preventDefault()
          e.stopPropagation()
          @gotoToday()
      when Keys.Plus
        # масштаб
        @incPixelsPerDay()
      when Keys.Minus
        # масштаб
        @decPixelsPerDay()

  incPixelsPerDay: ->
    @setPixelsPerDay Math.min(@model.pixels_per_day+5, MAX_PIXELS_PER_DAY)

  decPixelsPerDay: ->
    @setPixelsPerDay Math.max(@model.pixels_per_day-5, MIN_PIXELS_PER_DAY)

  setPixelsPerDay: (pixels_per_day) ->
    scale = @getScaleForPixelsPerDay(pixels_per_day)
    @model.set "scale", scale if scale != @model.get("scale")
    @model.pixels_per_day = pixels_per_day
    @setScale()

  getScaleForPixelsPerDay: (pixels_per_day)->
    if pixels_per_day > @model.MONTH_PIXELS_PER_DAY
      "week"
    else if pixels_per_day > @model.YEAR_PIXELS_PER_DAY
      "month"
    else
      "year"

  setScale: ->
    @timeline_view.resetScale()
    @update()

  gotoToday: ->
    @model.setToday()
    @gotoDate @model.getCurrentDate()

  gotoCurrentDate: ->
    @gotoDate @model.getCurrentDate()

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
    $(@el).html('')

    @timeline_view ||= new Potee.Views.TimelineView
      dashboard: @model
      dashboard_view: this
    @timeline_view.render()
    @$el.append @timeline_view.el

    @projects_view = new Potee.Views.Projects.IndexView
      projects: @model.projects
    @$el.append @projects_view.el

    this

  update: ->
    @resetWidth()
    @render()

  # Перейти на указанную дату (отцентировать).
  # @param [Date] date
  gotoDate: (date) ->
    x = @model.middleOffsetOf date
    return if @viewport.scrollLeft() == x
    @programmedScrolling = true
    @viewport.stop().animate { scrollLeft: x }, 1000, 'easeInOutExpo' #, => @programmedScrolling = false
    setTimeout (=>@programmedScrolling = false), 1200 # оказалось, что это надёжнее callback'a выше
    setTimeout (=>@resetTodayLink undefined), 1000


  #
  allowScrollByDrag: ->
    $('#dashboard').mousedown (e) =>
      if e.offsetX >= $('#dashboard').width() - 20 # вертикальный скролл справа.
        return
      @prev_x = e.screenX
      @prev_y = e.screenY
      @mouse_down = true
      @dragging = false

    $document = $(document)

    $document.mousemove (e) =>
      if @mouse_down && !@dragging
        @dragging = true
        @viewport.css("cursor", "move")

      if @dragging
        @viewport.scrollLeft @viewport.scrollLeft() - (e.screenX - @prev_x)
        $projects = @projects_view.$el
        $projects.scrollTop $projects.scrollTop() - (e.screenY - @prev_y)
        @prev_x = e.screenX
        @prev_y = e.screenY

    $document.mouseup =>
      @mouse_down = false
      if @dragging
        @dragging = false
        @viewport.css("cursor", "")


