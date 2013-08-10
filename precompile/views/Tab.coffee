Row = require './Row'
Cell = require './Cell'

module.exports = class Tab
# has one or more views
  constructor: (o) ->
    @name = o.name or 'untitled'
    Window.active_tab = @ if o.active
    @resize x: o.x, y: o.y, w: o.w, h: o.h
    @rows = []; @views = []
    row = new Row tab: @, x: @x, y: @y, w: @w, h: @ih, ph: 1
    cell = new Cell row: row, pw: 1
    cell.new_view tab: @, file: o.file, active: o.active
    return
  destroy: ->
  resize: (o) ->
    @x = o.x if o.x
    die "Tab.x may not be less than 1!" if @x < 1
    @y = o.y if o.y
    die "Tab.y may not be less than 1!" if @y < 1
    @w = o.w
    die "Tab.w may not be less than 1!" if @w < 1
    # outer
    @h = o.h
    die "Tab.h may not be less than 1!" if @h < 1 # TODO: or 2 if tab bar is present
    # inner
    @ih = o.h # optionally without a tab bar
    @draw()
    if @views then for view in @views
      view.resize x: @cell.x, y: @cell.y, w: @cell.w, h: @cell.h
    return
  draw: ->
    # if draw_tab_bar
    return

  activate_view: (view) ->
    v.active = v is view for v in @views
    return
  split: (dir, file) ->
    # TODO: account for divider width during resize
    divider_w = 1
    # TODO: draw divider;
    #       instead of blanking the whole screen and then not drawing views there
    #       be prepared to simply draw a line for the divider horizontally or vertically where it goes

    # resize all view coordinates and dimensions to make room
    # and initialize new view in the resulting space
    new_view = @active_view.cell[dir+'split']
      tab: Window.active_tab
      file: file

    # move focus to new view
    return @activate_view new_view
