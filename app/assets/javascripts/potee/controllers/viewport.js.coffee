class Potee.Controllers.Viewport extends Marionette.Controller
  initialize: (options) ->
    { @$viewport, @timeline_view } = options

    @$el = @$viewport

  # TODO
  isProjectOnViewport: (project) ->
    moment(project.started_at) <= @leftVisibleMoment() && moment(project.finish_at) >= @leftVisibleMoment()

    # @isDateOnViewport(project.started_at) and @isDateOnViewport(project.finish_at)

  # TODO Перенести во viewport_controller
  isDateOnViewport: (date) ->
    left = @scrollLeft() 
    right = left + @width()
    offset =  @timeline_view.offsetInPixels date
    left < offset < right

  momentOfTheMiddle: ->
    @timeline_view.momentAt @scrollLeft() + (@width() / 2)

  todayIsPassed: ->
    left = @scrollLeft()
    # right = left + @view.viewportWidth()
    offset =  @timeline_view.offsetInPixels @today
    offset < left

  leftVisibleMoment: ->
    @timeline_view.momentAt @scrollLeft()

  rightVisibleMoment: ->
    @timeline_view.momentAt @scrollLeft() + @width()

  scrollLeft: ->
    @$el.scrollLeft()

  width: ->
    @$el.width()

