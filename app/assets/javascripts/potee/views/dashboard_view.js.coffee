class Potee.Views.DashboardView extends Backbone.View
  initialize: (options)->
    { @viewport, @projects_view, @timeline_view, @dashboard_info } = options

    @model.view = @

    @_shown = false

  updateScaleCss: =>
    scale = @timeline_view.getScaleMode()

    @$el.removeClass("scale-days")
    @$el.removeClass("scale-weeks")
    @$el.removeClass("scale-months")

    @$el.addClass("scale-#{scale}")

    if @timeline_view.columnWidth()<=65
      @$el.addClass 'scale-days-ultra'
    else
      @$el.removeClass 'scale-days-ultra'

  resetWidth: (width) =>
    # А может быть он должен быть размером с projects? Ведь он их вмещает
    @$el.css 'width', width #@viewport.width()

  left: ->
    @$el.offset().left

  width: ->
    @$el.width()

  show: ->
    unless @_shown
      @_bindes()
      @render()

    @_shown = true

  _bindes: ->
    $('#dashboard').bind "pinch", (e, obj) => @model.pinch obj.scale

    # Это должно происходить при изменеии вида timeline-а в timeline-е
    # а не на каждый пиксель
    @listenTo @model, 'change:pixels_per_day', @updateScaleCss

    # Устанавливаем ширину dashboard-а на основании ширины timeline, как только она изменилась
    PoteeApp.seb.on 'timeline:reset_width', @resetWidth

  render: ->

    @timeline_view.render()
    @projects_view.render()

    @updateScaleCss()

    @
