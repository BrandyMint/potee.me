class Potee.Controllers.DragScroller
  constructor: (options) ->
    { @viewport_el, @dashboard_el, @projects_view } = options
    
    @dashboard_el.mousedown (e) =>
      if e.offsetX == @dashboard_el.width() - 20 # вертикальный скролл справа.
        return
      @prev_x = e.screenX
      @prev_y = e.screenY
      @mouse_down = true
      @dragging = false

    $document = $(document)

    $document.mousemove (e) =>
      if @mouse_down && !@dragging
        @dragging = true
        @viewport_el.css("cursor", "move")

      if @dragging
        @viewport_el.scrollLeft @viewport_el.scrollLeft() - (e.screenX - @prev_x)
        $projects = @projects_view.$el
        $projects.scrollTop $projects.scrollTop() - (e.screenY - @prev_y)
        @prev_x = e.screenX
        @prev_y = e.screenY

    $document.mouseup =>
      @mouse_down = false
      if @dragging
        @dragging = false
        @viewport_el.css("cursor", "")
