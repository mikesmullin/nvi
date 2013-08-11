module.exports = class BufferViewCursor
# belong to a user
# belong to a view
# cursors can also highlight and block edit

  # positioning of cursor relative to buffer
  go: (@x, @y) -> # relative to view
    Terminal.go(@view.x + @view.gutter.length + @x-1, @view.y + @y-1).flush()
    return
  move: (x, y=0) ->
    # TODO: limit cursor movement to within the typeable area, not the entire view
    dx = @x + x; dy = @y + y
    if dx >= 1 and dx <= @view.iw - @view.gutter.length and dy >= 1 and dy <= @view.ih
      @go dx, dy
    return
