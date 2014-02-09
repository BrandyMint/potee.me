Potee.Views.Titles ||= {}

class Potee.Views.Titles.ShowView extends Marionette.ItemView

  template: "templates/titles/show"
  className: 'title'

  initialize: ->
    @sticky_pos = undefined
