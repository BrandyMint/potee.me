class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'
  #

  initialize: (options)->
    @viewport =$('#viewport')
    @model.view = this
    @setElement($('#dashboard'))
    @update()

    @programmedScrolling = false

    _.bindAll(this, 'scroll')
    @viewport.bind('scroll', @scroll)

    _.bindAll(this, 'keydown')
    $(document).bind('keydown', @keydown)

    _.bindAll(this, 'click')
    $(document).bind('click', @click)

    $('#new-project-link').bind('click', @newProject)

    @allowScrollByDrag()

    @currentForm = undefined
    @todayLink = undefined

  click: (e) ->
    if @currentForm and $(e.target).closest(@currentForm.$el).length == 0
      @cancelCurrentForm()

  newProject: (e)->
    e.stopPropagation()
    e.preventDefault()

    $('#project_new').addClass('active')

    project = new Potee.Models.Project
    window.projects_view.addOne project, true
    project.view.setTitleView 'new'
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

  scroll: (e)->

    if @programmedScrolling
      @programmedScrolling = false
      return false

    # Если мы сменили масштаб где физиески нельзя поставить сегодняшнюю дату
    # 
    if @viewportWidth()>=@$el.width()
      return true

    # TODO Тоже для правого края

    if @model.currentDate or @viewport.scrollLeft()>1
      @$el.stop()
      date =  @model.dateOfMiddleOffset @viewport.scrollLeft()
      @model.setCurrentDate date

  keydown: (e) =>
    e ||= window.event

    switch e.keyCode
      when 27
        e.preventDefault()
        e.stopPropagation()
        @cancelCurrentForm(e)
      when 13
        @newProject(e) unless @currentForm
      when 32
        unless @currentForm
          e.preventDefault()
          e.stopPropagation()
          @gotoToday()

  setScale: (scale) ->
    @timeline_view.resetScale scale
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
      @currentForm.cancel()
    @currentForm = form_view

  resetWidth: ->
    @model.findStartEndDate()

    viewportWidth = @viewportWidth() # @viewport.width()
    if viewportWidth > @model.width()
      @model.setWidth(viewportWidth)

    @$el.css('width', @model.width())

  viewportWidth: ->
    @viewport.width()
    # @$el.parent().width()

  render: ->
    # @timeline_zoom_view = new Potee.Views.TimelineZoomView
    #
    @timeline_view ||= new Potee.Views.TimelineView
      dashboard: @model
      dashboard_view: this

    @timeline_view.render()
    @$el.append @timeline_view.el

    @projects_view = new Potee.Views.Projects.IndexView
      projects: @model.projects

    @$el.append @projects_view.el
    return this

  update: ->
    $(@el).html('')
    @resetWidth()
    @render()
    return

  gotoDate: (date) ->
    x = @model.middleOffsetOf date
    return if @viewport.scrollLeft() == x
    @programmedScrolling = true

    @viewport.stop().animate { scrollLeft: x }, 1000, 'easeInOutExpo'

  #
  allowScrollByDrag: ->
    @viewport.mousedown (e) =>
      @viewport.css("cursor", "move")
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
        window.scrollBy(0, -(e.screenY - @prev_y))
        @prev_x = e.screenX
        @prev_y = e.screenY

    $document.mouseup =>
      @mouse_down = false
      if @dragging
        @dragging = false
        @viewport.css("cursor", "")


