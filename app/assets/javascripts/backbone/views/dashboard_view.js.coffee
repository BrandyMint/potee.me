class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'
  #

  initialize: (options)->
    @model.view = @

    @viewport = options.$viewport
    @projects_view = options.projects_view
    @timeline_view = options.timeline_view
    @dashboard_info = options.dashboard_info

    $('#dashboard').bind "pinch", (e, obj) =>
      @model.pinch obj.scale

    # Это должно происходить при изменеии вида timeline-а,
    # а не на каждый пиксель
    @listenTo @model, 'change:pixels_per_day', @updateScaleCss

    # Устанавливаем ширину dashboard-а на основании ширины timeline, как только она изменилась
    PoteeApp.vent.on 'timeline:stretched', @resetWidth

  updateScaleCss: =>
    scale = @model.getTitle()

    @$el.removeClass("scale-week")
    @$el.removeClass("scale-month")
    @$el.removeClass("scale-year")

    @$el.addClass("scale-#{scale}")

  resetWidth: =>
    @$el.css 'width', @viewport.width()

  left: ->
    @$el.offset().left

  render: ->
    @timeline_view.render()
    @projects_view.render()

    @resetWidth()

    @
