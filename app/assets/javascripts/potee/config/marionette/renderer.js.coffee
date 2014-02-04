do (Marionette)->
  Marionette.Renderer.render = (template, data)->
    return if template is false

    template = template(data) if typeof template is "function"
    path = JST["potee/" + template]

    unless path
      throw "Template #{template} not found!"

    path(data)
