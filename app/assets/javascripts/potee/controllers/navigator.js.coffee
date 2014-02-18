class Potee.Navigator extends Marionette.Controller
  constructor: (options) ->
    { @dashboard } = options

    @history = Backbone.history
    @listenTo @dashboard, 'change:pixels_per_day', @updateUrl
    PoteeApp.seb.on 'project:current', @updateUrl
    PoteeApp.seb.on 'dashboard:mode',  @updateUrl

  updateUrl: =>
    @history.navigate @fragment()

  fragment: ->
    console.log 'fragment', PoteeApp.seb.get('dashboard:mode')
    f = ''
    if PoteeApp.seb.get('dashboard:mode') is 'entire'
      f = 'entire/'+PoteeApp.seb.get('project:current').get('project_id')
    else
      f = 'scale/'+@dashboard.get('pixels_per_day')
