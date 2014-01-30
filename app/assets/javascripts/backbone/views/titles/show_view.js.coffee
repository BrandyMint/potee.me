Potee.Views.Titles ||= {}

class Potee.Views.Titles.ShowView extends Marionette.ItemView
  template: JST["backbone/templates/titles/show"]
  tagName: "div"
  className: 'project-title'

  initialize: (@options) ->
    @sticky_pos = undefined