class Potee.Views.DashboardView extends Backbone.View
  id: 'dashboard'
  tagName: 'div'

  events:
    "click #timeline-zoom .btn" : "zoom"

  initialize: (options)->
    @dashboard = options.dashboard
    @render()

  zoom: (event) ->
    level = event.target.getAttribute('data-zoom-level')
    switch level
      when 'days' then @timeline_view = new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
      when 'weeks' then @timeline_view = new Potee.Views.Timelines.WeeksView(moment(@dashboard.min), moment(@dashboard.max))
      when 'months' then @timeline_view = new Potee.Views.Timelines.MonthsView(moment(@dashboard.min), moment(@dashboard.max))
    @render()

  render: ->
    # TODO Рендерим projects
    @projects_view = new Potee.Views.Projects.IndexView(projects: @dashboard.projects)
    @$.append @projects_view.el

    @timeline_view ||= new Potee.Views.Timelines.DaysView(moment(@dashboard.min), moment(@dashboard.max))
    $("#timeline").html(@timeline_view.render().el)

    return this
