class Potee.Controllers.ScalePanel
  constructor: (options)->
    @dashboard = options.dashboard
    @dashboard.on 'change:pixels_per_day', @resetScale

  resetScale: =>
    scale = @dashboard.getTitle()

    $('#scale-nav a').removeClass('active')
    $("#scale-#{scale}").addClass('active')
