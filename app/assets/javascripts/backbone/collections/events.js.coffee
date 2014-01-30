class Potee.Collections.EventsCollection extends Backbone.Collection
  model: Potee.Models.Event
  url: '/events'

  initialize: (options) ->
    @on 'remove', (model) ->
      model.destroy()
    @project = options.project

  getClosestEvent: () ->
    diff_seconds = 31536000 #количество секунд в году, пойдет для первоначального значения
    closest_event = this.last
    this.each((event) =>
      diff = Math.abs(moment(event.date).diff(moment(), "seconds")) 
      if diff < diff_seconds  
        closest_event = event
        diff_seconds = diff
    )
    return closest_event
