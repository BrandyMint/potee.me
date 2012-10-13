class Potee.Views.TimelineZoomView extends Backbone.View
  template: JST["backbone/templates/timeline_zoom"]
  id: 'timeline-zoom'
  tagName: 'div'

  initialize: ->
    @render()

  events:
    "click .zoom-control .btn" : "changeScale"

  changeScale: (event) ->
    @setScale event.target.getAttribute('data-zoom-level')

  setScale: (scale) ->
    window.dashboard.set('scale', scale)
    window.dashboard.view.render()
    @activateScale scale

  activateScale: (scale) ->
    @$el.find('.btn').removeClass('active btn-primary')
    $("#scale-#{scale}").addClass('active btn-primary')

  render: ->
    $(@el).html(@template)
    $('#timeline-zoom-container').html @el
    @activateScale window.dashboard.get('scale')

    return this

