class Potee.Navigator extends Marionette.Controller
  constructor: (options) ->
    { @dashboard } = options

    @history = Backbone.history
    @listenTo @dashboard, 'change:pixels_per_day', @updateUrl

  updateUrl: =>
    url = @getFragment()
    @history.navigate url

  getFragment: ->
    if PoteeApp.seb.get('dashboard:entire')?
      return '/entire/' + PoteeApp.seb.get('dashboard:entire')
    else
      '/scale/' + @dashboard.get('pixels_per_day')
