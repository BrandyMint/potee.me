class Potee.Navigator extends Marionette.Controller
  constructor: (options) ->
    { @dashboard } = options

    @history = Backbone.history
    @listenTo @dashboard, 'change:pixels_per_day', @updateUrl

  updateUrl: =>
    return if PoteeApp.seb.get('dashboard:mode') is 'entire'
    url = @fragment_pixels()
    @history.navigate url

  fragment_pixels: ->
    '/scale/'+@dashboard.get('pixels_per_day')
