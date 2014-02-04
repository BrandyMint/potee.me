class Potee.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
  routes:
    ""          : "index"
    "index"     : "index"
    'days'      : 'days'
    'weeks'     : 'weeks'
    'months'    : 'months'
    ".*"        : "index"
    # иначе не ловится редирект из фейсбука #_=_
    ":some"       : "index"

  index: ->

  days: ->
    @setScale 'week'

  weeks: ->
    @setScale 'month'

  months: ->
    @setScale 'year'

  setScale: (scale_name) ->
    return if scale_name == window.dashboard.getTitle()
    switch scale_name
      when 'week' then pixels = Potee.Models.Dashboard.prototype.DEFAULT_WEEK_PIXELS_PER_DAY
      when 'month' then pixels = Potee.Models.Dashboard.prototype.DEFAULT_MONTH_PIXELS_PER_DAY
      when 'year' then pixels = Potee.Models.Dashboard.prototype.DEFAULT_YEAR_PIXELS_PER_DAY
      else throw "Unknown scale title #{scale_name}"

    window.dashboard.set 'pixels_per_day', pixels
