View = require './View'
Cursor = require './Cursor'

module.exports = class Tab
# has many views
  constructor: (o) ->
    @name = o.name or 'untitled'
    Window.active_tab = @ if o.active
    @resize x: o.x, y: o.y, w: o.w, h: o.h
    @views = [new View tab: @, file: o.file, x: @x, y: @y, w: @w, h: @ih, active: o.active] # can never have fewer than one view
  resize: (o) ->
    @x = o.x
    die "Tab.x may not be less than 1!" if @x < 1
    @y = o.y
    die "Tab.y may not be less than 1!" if @y < 1
    @w = o.w
    die "Tab.w may not be less than 1!" if @w < 1
    # outer height
    @h = o.h
    die "Tab.h may not be less than 1!" if @h < 1 # TODO: or 2 if tab bar is present
    # inner height
    @ih = o.h # optionally without a tab bar
    @draw()
    if @views
      view.resize w: @w, h: @ih for view in @views
  draw: ->
    # if draw_tab_bar
