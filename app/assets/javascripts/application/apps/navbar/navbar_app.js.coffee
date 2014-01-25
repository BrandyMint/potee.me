@Potee.module "NavbarApp", (NavbarApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: ->
      new NavbarApp.Show.Controller

  NavbarApp.on "start", ->
    API.show()