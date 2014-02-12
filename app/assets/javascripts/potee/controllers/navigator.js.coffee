class Potee.Navigator extends Marionette.Controller
  constructor: (options) ->
    { @dashboard } = options

    @history = Backbone.history
    @listenTo @dashboard, 'change:pixels_per_day', @updateUrl

  updateUrl: =>
    @history.navigate @fragment()

  fragment: ->
    if PoteeApp.seb.get('dashboard:mode') is 'entire'
      'entire/'+PoteeApp.seb.get('project:current').get('project_id')
    else
      '/scale/'+@dashboard.get('pixels_per_day')
