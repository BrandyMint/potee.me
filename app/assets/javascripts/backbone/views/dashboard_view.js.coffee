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
    $(document).bind 'click', (e)=>
      if @currentForm and $(e.target).closest(@currentForm.$el).length == 0
        @cancelCurrentForm()

    @currentForm = undefined

  scroll: (e)->
    if @programmedScrolling
      @programmedScrolling = false
      return false

    # Если мы сменили масштаб где физиески нельзя поставить сегодняшнюю дату
    # 
    if @viewportWidth()>=@$el.width()
      return true

    # TODO Тоже для правого края
    date =  @model.dateOfMiddleOffset @viewport.scrollLeft()

    if @model.currentDate or @viewport.scrollLeft()>1
      @model.setCurrentDate date


  keydown: (e) =>
    e.stopPropagation()
    if e.keyCode == 27
      e ||= window.event
      e.preventDefault()
      @cancelCurrentForm(e)

  setScale: (scale) ->
    @timeline_view.resetScale scale
    @update()

  gotoCurrentDate: ->
    console.log 'gotoCurrentDate', @model.getCurrentDate().toString()
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
    # console.log 'gotoDate', date.toString()
    x = @model.middleOffsetOf date
    # console.log 'gotoScroll', x
    return if @viewport.scrollLeft() == x
    @programmedScrolling = true
    @viewport.scrollLeft x

  gotoDay: (day) ->
    x = @model.middleOffsetOf( day )
    # console.log 'gotoDay', day, x
    return if @viewport.scrollLeft() == x
    @programmedScrolling = true
    @viewport.scrollLeft x
