class Potee.Views.ScalePanel extends Marionette.ItemView
  template: 'templates/scale_nav'
  el: '#scale-nav'

  ui:
    days:   '#scale-days'
    weeks:  '#scale-weeks'
    months: '#scale-months'
    all:    'a'

  onRender: ->
    PoteeApp.seb.on 'timeline:scale_mode', @updateCSS

    @ui.days.attr 'href',   "#scale/" + Potee.Controllers.Scaller.prototype.DEFAULT_WEEK_PIXELS_PER_DAY
    @ui.weeks.attr 'href',  "#scale/" + Potee.Controllers.Scaller.prototype.DEFAULT_MONTH_PIXELS_PER_DAY
    @ui.months.attr 'href', "#scale/" + Potee.Controllers.Scaller.prototype.DEFAULT_YEAR_PIXELS_PER_DAY

    @updateCSS window.timeline_view.getScaleMode()

  updateCSS: (scale_mode) =>
    # Повторно байндим, потому что top_panel при удалении главного меню теряет привязки
    @unbindUIElements()
    @bindUIElements()
    @ui.all.removeClass 'active'
    @ui[scale_mode].addClass 'active'
