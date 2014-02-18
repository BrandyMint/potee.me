class Potee.Controllers.Viewport extends Marionette.Controller
  initialize: (options) ->
    { @$viewport, @timeline_view } = options

    @$el = @$viewport

  isProjectOnViewPort: (project) ->
    @isDateOnViewport(project.started_at) and @isDateOnViewport(project.finish_at)

  # TODO Перенести во viewport_controller
  isDateOnViewport: (date) ->
    left = @scrollLeft() 
    right = left + @width()
    offset =  @timeline_view.offsetInPixels date
    left < offset < right

  scrollLeft: ->
    @$el.scrollLeft()

  width: ->
    @$el.width()

