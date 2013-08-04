View = require './View'
Cursor = require './Cursor'

module.exports = class Tab
# has many views
  constructor: (o) ->
    @name = o?.name or 'untitled'
    @w = o.w
    @h = o.h
    @views = [new View tab: @, file: o?.file, x: 0, y: 0, w: @w, h: @h] # can never have fewer than one view
    @active_view = @views[0]
  resize: ->
    view.resize() for view in @views
    @draw()
  draw: ->
    # if draw_tab_bar
    view.draw() for view in @views
