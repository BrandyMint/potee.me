class Potee.Controllers.CurrentForm
  constructor: (options) ->
    @currentForm = undefined

    _.extend @, Backbone.Events

    PoteeApp.vent.on 'current_form:canceled', @canceled
    PoteeApp.vent.on 'current_form:set', @setCurrentForm
    PoteeApp.reqres.setHandler 'current_form:editing?', =>
      @currentForm?

    PoteeApp.vent.on 'escape', @cancel

    $(document).bind 'click', @click

  click: (e) =>
    if @currentForm? and $(e.target).closest(@currentForm.$el).length == 0
      @cancel()

  cancel: =>
    console.log "cancel current_form #{@currentForm}"
    @currentForm?.cancel()

  setCurrentForm: (form_view) =>
    if form_view == @current_form
      debugger # exception
      throw 'strange'

    @cancel()

    @currentForm = form_view

    console.log "set current_form = #{form_view}"

    @listenTo @currentForm, 'close', =>
      @canceled @currentForm

    # event title не закрывается, поэтому ему приходится генерировать cancel вместо close
    @listenTo @currentForm, 'cancel', =>
      @canceled @currentForm

  canceled: (form_view) =>
    if form_view == @currentForm
      console.log 'remove current_form'
      @stopListening @currentForm
      @currentForm = undefined

