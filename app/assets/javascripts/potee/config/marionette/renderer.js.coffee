do (Marionette)->
  Marionette.Renderer.render = (template, data)->
    return if template is false

    if typeof template is "function"
      template data
    else
      path = JST["potee/" + template]

      unless path
        throw "Template #{template} not found!"

      path(data)
