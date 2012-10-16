class Potee.Views.TimelineView extends Backbone.View
  id: 'timeline'
  tagName: 'div'

  scale: 'days'

  initialize: ->
    @dashboard = @options.dashboard
    @view = @options.view

  resetScale: ->
    scale = @dashboard.get('scale')

    $('#scale-nav a').removeClass('active')
    $("#scale-#{scale}").addClass('active')

    @dashboard.view.$el.removeClass("scale-day")
    @dashboard.view.$el.removeClass("scale-month")
    @dashboard.view.$el.removeClass("scale-year")

    @dashboard.view.$el.addClass("scale-#{scale}")

    switch scale
      when 'week'   then @scaleClass = Potee.Views.Timelines.DaysView
      when 'month'  then @scaleClass = Potee.Views.Timelines.WeeksView
      when 'year' then @scaleClass = Potee.Views.Timelines.MonthsView
      else console.log('unknown scale ' + scale)

    @currentView = new @scaleClass
      date_start: moment(@dashboard.min_with_span())
      date_finish: moment(@dashboard.max_with_span())
      column_width: @dashboard.pixels_per_day
      dashboard: @dashboard
      time_line: this

    @$el.html @currentView.render().el

  render: ->
    @resetScale()

    # В Firefox стиль отображения для td должен быть дефолтным в отличии от Chrome
    if $.browser.mozilla
      @$el.find('td').css('display', 'table-cell')

    return this

