class Potee.Models.Event extends Backbone.Model
  paramRoot: "event"

  initialize: ->
    @date = moment(@get("date")).toDate()
    @time = moment(@get("time")).toDate()
    @project_started_at = @collection.project.started_at

  days_to_scale: (scale) ->
    switch scale
      when "days"
        1
      when "weeks"
        7
      when "months"
        31

class Potee.Collections.EventsCollection extends Backbone.Collection
  model: Potee.Models.Event
  url: '/events'

  initialize: (options) ->
    @project = options.project
