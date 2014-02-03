class Potee.Regions.SlideInSlideOutRegion extends Backbone.Marionette.Region

  open: (view) ->
    @$el.hide()
    @$el.html view.el
    @$el.slideDown "fast"

  close: ->
    view = @currentView
    return if !view
    
    that = @
    @$el.css 'background-color', 'white'
    @$el.slideUp "fast", ->
      if view.close 
        view.close()
      that.trigger "view:closed", view
      
      delete @currentView