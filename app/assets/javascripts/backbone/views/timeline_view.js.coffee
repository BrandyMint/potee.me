class Potee.Views.TimelineView extends Backbone.View
  id: 'timeline'
  tagName: 'div'

  initialize: ->
    @dashboard = @options.dashboard
    @view = @options.view

  render: ->
    # TODO [AK 13/10/12] render view depends on user settings
    @view ||= new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
    @$el.html(@view.render().el)

    return this

