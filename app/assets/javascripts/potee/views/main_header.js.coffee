class Potee.Views.MainHeader extends Marionette.ItemView
  initialize: ->
    @template = _.template $('#main_header').html()

  serializeData: ->
    {}

  onRender: ->
    # @topPanelRegion = new Marionette.Region el: el
    @sp = new Potee.Views.ScalePanel el: @$el.find('#scale-nav')
    @sp.render()

    _.defer =>
      @$el.fadeIn()

    @$el

  onClose: ->
    @sp.close()
