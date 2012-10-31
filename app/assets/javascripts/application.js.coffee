#= require jquery
#= require jquery_ujs
#= require jquery.effects.bounce
#= require jquery.ui.resizable
#= require jquery.ui.draggable
#= require underscore
#= require moment
#= require moment-range
#= require backbone
#= require backbone_rails_sync
#= require backbone_datalink
#= require backbone/potee
#= require bootstrap
#= require_tree .
  
window.hideShow = (object_source, object_target) ->
  object_source.bind 'click', (e) ->
    e.preventDefault()
    object_target.toggleClass('hidden')

$ ->
  $('[rel=tooltip]').tooltip()
