# Statefull EventerBroadcaster on Backbone.Model
#
# https://gist.github.com/dapi/8807307
window.A = {}
class A.StatedEventBroadcaster extends Backbone.Model
  fire: (path, value)    -> @set path, value
  on:   (path, callback) ->
    Backbone.Model.prototype.on.call @, "change:#{path}", (m, value) -> callback value 

  off:  (path, callback) ->
    Backbone.Model.prototype.off.call @, "change:#{path}", (m, value) -> callback value
