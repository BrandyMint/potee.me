Potee.Views.Titles ||= {}

class Potee.Views.Titles.ShowView extends Marionette.ItemView

  template: "templates/titles/show"
  className: 'project-title'

  initialize: (@options) ->
    @sticky_pos = undefined
