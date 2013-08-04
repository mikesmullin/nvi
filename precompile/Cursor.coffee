module.exports = class Cursor
# belong to a user
# belong to a hydrabuffer
# cursors can also highlight and block edit
  constructor: (o) ->
    @user = o.user
    @view = o.view
    @resize x: o.x, y: o.y, w: o.w, h: o.h
  resize: (o) ->
    @x = o.x
    die "Cursor.x may not be less than 1!" if @x < 1
    @y = o.x
    die "Cursor.y may not be less than 1!" if @y < 1
    @w = 1
    die "Cursor.w may not be less than 1!" if @w < 1
    @h = 1
    die "Cursor.h may not be less than 1!" if @h < 1
  go: (@x, @y) -> # relative to view
    Logger.out "View.cursor = x: #{@x}, y: #{@y}"
    Terminal.go @view.x-1 + @view.gutter.length + @x-1, @view.y + @y-1
  move: (x, y=0) -> # relative to current position
    # TODO: limit cursor movement to within the typeable area, not the entire view
    #Logger.out "called cursor.move() #{x}, #{y}"
    #Logger.out "view.w #{@view.w}, view.h #{@view.h}, view.gutter.length #{@view.gutter.length}"
    dx = @x + x; dy = @y + y
    #Logger.out "dx #{dx}, dy #{dy}"
    if dx >= 1 and dx <= @view.w - @view.gutter.length and dy >= 1 and dy <= @view.ih
      @go dx, dy
  draw: ->
    # mainly used to draw other people's cursors
