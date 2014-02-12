class Potee.Models.Dashboard extends Backbone.Model
  url: '/'

  methodToURL:
    'read': '/dashboard/read',
    'update': '/dashboard/update'

  sync: (method, model, options) ->
    options = options || {}
    options.url = model.methodToURL[method.toLowerCase()]
    Backbone.sync(method, model, options)

  getCurrentDate: ->
    @getCurrentMoment().toDate()

  setCurrentDate: (date) ->
    @set 'current_date', date?.toISOString()

  setToday: ->
    @setCurrentDate undefined

  getCurrentMoment: ->
    moment @get('current_date')