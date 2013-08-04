module.exports = class Cursor
# belong to a user
# belong to a hydrabuffer
# cursors can also highlight and block edit
  constructor: (o) ->
    @user = o.user
    @view = o.view
    @x = o.x or 1
    @y = o.x or 1
    @w = 1
    @h = 1
  go: (x, y) -> # relative to view
    @x = x or 1
    @y = y or 1
    Terminal.go @view.x + @view.gutter_width + @x, @view.y + @y
    Logger.out "cursor now #{@x}, #{@y}"
  move: (x, y=0) -> # relative to current position
    Logger.out "called cursor.move() #{x}, #{y}"
    Logger.out "view.w #{@view.w}, view.h #{@view.h}, view.gutter_width #{@view.gutter_width}"
    dx = @x + x
    dy = @y + y
    Logger.out "dx #{dx}, dy #{dy}"
    if dx >= 0 and dx <= @view.w - @view.gutter_width and dy >= 0 and dy <= @view.h
      @go dx, dy
