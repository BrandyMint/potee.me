class Potee.Controllers.EditFormPositioner
  #constructor: ->
    #PoteeApp.vent.on 'project:rendered', @projectAdded

  #projectAdded: (view) =>
    #return unless view.isEditing()

    #offset = view.$el.offset()
    #top  = offset.top
    #left = offset.left
    #bottom = top + view.$el.height()
    #right = left + view.$('form').width()

    #va_left   = $('#viewport').scrollLeft()
    #va_right  = va_left + $('#viewport').width()
    #va_top    = $('#projects').scrollTop()
    #va_bottom = va_top + $('#viewport').height()

    #$('#projects').animate {
      #scrollTop: offset.top
    #}, 500
    
    #$('#viewport').scrollLeft offset.left
