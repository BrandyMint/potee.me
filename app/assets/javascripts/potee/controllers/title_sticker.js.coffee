class Potee.Controllers.TitleSticker
  constructor: (options)->
    { @dashboard, @timeline_view, @projects, @projects_view } = options

  #resetStickyTitles: =>
    #return false unless @projects_view.el
    ##console.log 'reset sticky titles'

    ## переменная @model в цикле не достпна
    #@projects.each (project)  -> project.view?.resetStickyTitle()
