class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'

  initialize: (options)->
    @model.view = this
    @setElement($('#dashboard'))
    @update()

    @gotoDate moment()

    _.bindAll(this, 'on_keypress')
    $(document).bind('keydown', @on_keypress)

    $(document).bind 'click', (e)=>
      if @currentForm and $(e.target).closest(@currentForm.$el).length == 0
        @cancelCurrentForm()

    @currentForm = undefined

  on_keypress: (e) =>
    e.stopPropagation()
    if e.keyCode == 27
      e ||= window.event
      e.preventDefault()
      @cancelCurrentForm(e)

  setScale: (scale) ->
    @timeline_view.resetScale scale
    @update()

  cancelCurrentForm: (e) =>
    @setCurrentForm undefined

  setCurrentForm: (form_view) =>
    if @currentForm
      @currentForm.cancel()
    @currentForm = form_view

  resetWidth: ->
    @model.findStartEndDate()

    viewportWidth = $('#viewport').width()
    if viewportWidth > @model.width()
      @model.setWidth(viewportWidth)

    @$el.css('width', @model.width())

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
    @gotoDay @model.indexOf( date )

  gotoDay: (day) ->
    $('#viewport').scrollLeft @model.middleOffsetOf( day )
