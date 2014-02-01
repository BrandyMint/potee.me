class Potee.Controllers.DashboardPersistenter
  constructor: (options) ->
    @projects = options.projects
    Backbone.pEvent.on 'savePositions', @savePositions

  savePositions: () ->
    neworder = []
    $('#projects div.project').each () ->
      neworder.push $(this).attr("id")

    _.each neworder, (cid, i) ->
      project = @projects.get(cid)

      if project? && !project.isNew()
        project.set 'position', i
        console.log "save position #{i}"
        project.save()
