window.Potee.Mediators ||= {}

class Potee.Mediators.Keystrokes
  constructor: (options) ->
    @dashboard_view = options.dashboard_view
    @dashboard = options.dashboard

    Mousetrap.bind '0', =>
      unless @dashboard_view.currentForm
        @dashboard.setTitle 'week'

    Mousetrap.bind '+', =>
      unless @dashboard_view.currentForm
        @dashboard.incPixelsPerDay()

    Mousetrap.bind '-', =>
      unless @dashboard_view.currentForm
        @dashboard.decPixelsPerDay()

    Mousetrap.bind 'esc', (e)=>
      # отмена формы
      e.preventDefault()
      e.stopPropagation()
      @dashboard_view.cancelCurrentForm(e)

    Mousetrap.bind 'enter', (e)=>
      @dashboard_view.newProject(e) unless @dashboard_view.currentForm

    Mousetrap.bind 'space', (e)=>
      unless @dashboard_view.currentForm
        e.preventDefault()
        e.stopPropagation()
        @dashboard_view.gotoToday()
