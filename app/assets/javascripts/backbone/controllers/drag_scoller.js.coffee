class Potee.Controllers.DragScroller
  constructor: (options) ->
    @viewport = options.viewport
    @projects_view = options.projects_view

    options.$dashboard_el.mousedown (e) =>
      if e.offsetX = options.$dashboard_el.width() - 20 # вертикальный скролл справа.
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
