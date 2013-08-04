View = require './View'
Cursor = require './Cursor'

module.exports = class Tab
# has many views
  constructor: (o) ->
    @name = o.name or 'untitled'
    @w = o.w
    @h = o.h
    Window.active_tab = @ if o.active
    @views = [new View tab: @, file: o.file, x: 0, y: 0, w: @w, h: @h, active: o.active] # can never have fewer than one view
  resize: ({@w, @h}) ->
    @draw()
    view.resize w: @w, h: @h for view in @views
  draw: ->
    # if draw_tab_bar
