Potee.Views.Titles ||= {}

class Potee.Views.Titles.ShowView extends Marionette.ItemView

  template: "templates/titles/show"
  className: 'title'
  events:
    "click .title.sticky" : "sticky_title_click"

  initialize: (options) ->
    { @project_view } = options
    @sticky_pos = undefined

    Backbone.pEvent.on 'dashboard:scroll', @reset
    Backbone.pEvent.on 'projects:scroll',  @reset
    Backbone.pEvent.on 'projects:reorder', @reset
    PoteeApp.on        'projects:reset_scale', => _.defer @reset

  sticky_title_click: (e) ->
    PoteeApp.seb.fire 'project:current', @model
    e.stopPropagation()
    @gotoProjectEdge()

  # TODO вынести в controller
  gotoProjectEdge:() ->
    switch @sticky_pos
      when 'left'
        PoteeApp.commands.execute 'gotoDate', @model.finish_at
      when 'right' 
        PoteeApp.commands.execute 'gotoDate', @model.started_at

  onRender: ->
    @reset()

  stickTitle: (position = 'left') ->
    @sticky_pos = position
    top_value = @project_view.$el.offset().top + 49 #отступ для каждого title
    title_dom = @$el
    title_dom.addClass 'sticky'
    title_dom.css
      top: top_value + 'px'

    switch position
      when 'left'  then title_dom.css('left','0px')
      when 'right' then title_dom.css('right','0px')

  unstickTitle: ->
    @sticky_pos = undefined
    title_dom = @$el
    title_dom.removeClass 'sticky'
    title_dom.css
      top:  ''
      left: ''
      right:''

  isViewable: ->
    !window.timeline_view.isDateOnDashboard(@model.started_at) and
      window.projects_view.isProjectViewedVertically(@model)

  reset: =>
    if @isViewable()
      #console.log 'reset sticky titles 2', i
      if @model.started_at < window.dashboard.getCurrentDate()
        @stickTitle 'left'
      else
        @stickTitle 'right'
    else
      return if @sticky_pos == undefined
      @unstickTitle()
