window.Potee.Mediators.Keystrokes ||= {}

class Potee.Mediators.Keystrokes
  Keys =
    Enter: 13
    Escape: 27
    Space: 32
    Plus: 187
    Minus: 189

  constructor: (dashboard) ->
    @dashboard = dashboard
    $(document).bind('keydown', @keydown)

  keydown: (e) =>
    e ||= window.event
    switch e.keyCode
      when Keys.Escape
        # отмена формы
        e.preventDefault()
        e.stopPropagation()
        @dashboard.cancelCurrentForm(e)
      when Keys.Enter
        # новый проект
        @dashboard.newProject(e) unless @dashboard.currentForm
      when Keys.Space
        # перейти на сегодня
        unless @dashboard.currentForm
          e.preventDefault()
          e.stopPropagation()
          @dashboard.gotoToday()
      when Keys.Plus
        # масштаб
        unless @dashboard.currentForm
          @dashboard.incPixelsPerDay()
      when Keys.Minus
        # масштаб
        unless @dashboard.currentForm
          @dashboard.decPixelsPerDay()
