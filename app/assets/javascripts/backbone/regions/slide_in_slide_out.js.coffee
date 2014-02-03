class Potee.Regions.SlideInSlideOutRegion extends Backbone.Marionette.Region

  open: (view) ->
    # Если в регионе уже есть вьюха,
    currentView = @currentView
    if currentView
      currentView.close()
    else
      @$el.hide()
    @$el.html view.el
    @$el.css 'background-color', 'white'
    @$el.slideDown "fast"

  close: ->
    view = @currentView
    return if !view
    
    that = @
    @$el.slideUp "fast", ->
      if view.close 
        view.close()
      that.trigger "view:closed", view
      
      delete @currentView