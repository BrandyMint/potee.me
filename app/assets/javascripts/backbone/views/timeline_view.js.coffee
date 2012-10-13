class Potee.Views.TimelineView extends Backbone.View
  template: JST["backbone/templates/timeline"]
  id: 'timeline'
  tagName: 'div'

  initialize: ->
    @dashboard = @options.dashboard

  events:
    "click .zoom-control .btn" : "zoom"

  zoom: (event) ->
    level = event.target.getAttribute('data-zoom-level')
    switch level
      when 'days' then @view = new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
      when 'weeks' then @view = new Potee.Views.Timelines.WeeksView(moment(@dashboard.min), moment(@dashboard.max))
      when 'months' then @view = new Potee.Views.Timelines.MonthsView(moment(@dashboard.min), moment(@dashboard.max))
    @render()

  render: ->
    $(@el).html(@template)

    # TODO [AK 13/10/12] render view depends on user settings
    @view ||= new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
    @$el.append @view.render().el

    return this

