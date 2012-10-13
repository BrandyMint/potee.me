class Potee.Views.TimelineView extends Backbone.View
  id: 'timeline'
  tagName: 'div'

  initialize: ->
    @dashboard = @options.dashboard

  events:
    "click #timeline-zoom .btn" : "zoom"

  zoom: (event) ->
    level = event.target.getAttribute('data-zoom-level')
    switch level
      when 'days' then @timeline_view = new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
      when 'weeks' then @timeline_view = new Potee.Views.Timelines.WeeksView(moment(@dashboard.min), moment(@dashboard.max))
      when 'months' then @timeline_view = new Potee.Views.Timelines.MonthsView(moment(@dashboard.min), moment(@dashboard.max))
    @render()

  render: ->
    view = new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
    @$el.html view.render().el

    # TODO Рендерит нужную вьюху
    return this

