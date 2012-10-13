class Potee.Models.Project extends Backbone.Model
  paramRoot: 'project'

  defaults:
    title: 'проект без названия'

class Potee.Collections.ProjectsCollection extends Backbone.Collection
  model: Potee.Models.Project
  url: '/projects'
