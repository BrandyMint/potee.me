class Potee.Mediators.Keystrokes
  constructor: (options) ->
    @dashboard_view = options.dashboard_view
    @dashboard = options.dashboard

    Mousetrap.bind '0', =>
      #unless @isEditing()
      if @dashboard.getTitle() == 'week'
        @dashboard.setScale 'year'
      else
        @dashboard.setScale 'week'

    Mousetrap.bind '+', =>
      @dashboard.incPixelsPerDay()

    Mousetrap.bind '-', =>
      @dashboard.decPixelsPerDay()

    Mousetrap.bind 'esc', (e)=>
      # отмена формы
      #e.preventDefault()
      #e.stopPropagation()
      console.log 'triger escape'
      PoteeApp.vent.trigger 'escape'

    Mousetrap.bind 'enter', (e)=>
      #return if @isEditing()

      e.stopPropagation()
      e.preventDefault()

      PoteeApp.vent.trigger 'new_project'

    Mousetrap.bind 'space', (e)=>
      e.preventDefault()
      e.stopPropagation()
      PoteeApp.commands.execute 'gotoToday'

  isEditing: ->
    PoteeApp.reqres.request 'current_form:editing?'
