class Potee.Controllers.DashboardPersistenter
  constructor: (options) ->
    Backbone.pEvent.on 'savePositions', @savePositions

  savePositions: () ->
    projects = window.projects
    neworder = []
    $('#projects div.project').each () ->
      neworder.push $(this).attr("id")

    _.each neworder, (cid, i) ->
      project = projects.get(cid)

      if project? && !project.isNew()
        project.set 'position', i
        console.log "save position #{i}"
        project.save()
