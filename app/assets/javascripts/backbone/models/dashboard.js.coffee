class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 40

  # Сколько всего дней на столе
  days: 400

  getIndexOfDay: (date) ->
    # Возвращает индекс дня
    # Date.parse @get('started_at')
    return 1

