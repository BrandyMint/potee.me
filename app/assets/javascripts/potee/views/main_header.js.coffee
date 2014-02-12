class Potee.Views.MainHeader extends Marionette.ItemView
  initialize: ->
    @template = _.template $('#main_header').html()

  serializeData: ->
    {}

  #onRender: ->
    ## @topPanelRegion = new Marionette.Region el: el
    #_.defer =>
      #@$el.fadeIn()

    #@$el
