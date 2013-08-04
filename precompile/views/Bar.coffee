module.exports = class Bar
  constructor: (o) ->
    @last_text = ''
    @bg = o.bg or die "Bar.bg must be specified!"
    @fg = o.fg or die "Bar.fg must be specified!"
    @resize x: o.x, y: o.y, w: o.w, h: o.h
    return
  resize: (o) ->
    Logger.out "Bar.resize(#{JSON.stringify o}) called."
    @x = o.x if o.x
    die "Bar.x may not be less than 1!" if @x < 1
    @y = o.y
    die "Bar.y may not be less than 1!" if @y < 1
    @w = o.w
    die "Bar.w may not be less than 1!" if @w < 1
    @h = o.h if o.h
    die "Bar.h may not be less than 1!" if @h < 1
    @draw()
    return
  draw: ->
    @set_text @last_text
    return
  set_text: (s, return_cursor=true) ->
    Logger.out "Bar.set_text() called. "+JSON.stringify x: @x, y: @y, w: @w, h: @h, bg: @bg, fg: @fg
    Terminal
      .clear_space(x: @x, y: @y, w: @w, h: @h, bg: @bg, fg: @fg)
      .echo(s.substr(0, @w)).flush()
    @last_text = s
    Window.current_cursor()?.draw() if return_cursor # return cursor to last position
    return
