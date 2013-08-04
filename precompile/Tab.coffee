View = require './View'
Cursor = require './Cursor'

module.exports = class Tab
# has many views
  constructor: (o) ->
    @name = o.name or 'untitled'
    Window.active_tab = @ if o.active
    @resize w: o.w, h: o.h
    @views = [new View tab: @, file: o.file, x: 1, y: 1, w: @w, h: @ih, active: o.active] # can never have fewer than one view
  resize: (o) ->
    #@x = 0 # safe to assume
    #@y = 0
    @w = o.w
    die "Tab.w may not be less than 1!" if @w < 1
    # outer height
    @h = o.h
    die "Tab.h may not be less than 1!" if @h < 1
    # inner height
    @ih = o.h # optionally without a tab bar
    @draw()
    if @views
      view.resize w: @w, h: @ih for view in @views
  draw: ->
    # if draw_tab_bar
