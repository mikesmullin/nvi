module.exports = class Terminal
  @echo: (s) ->
    w_delta = s.length
    if w_delta
      s.replace(/[\r\n]+/, -> Terminal.cursor.y++; '') # only counts newlines
      #Logger.out "cx was #{Terminal.cursor.x}, cy was #{Terminal.cursor.y}"
      #Logger.out "s.length #{w_delta} s=\"#{s}\""
      #Logger.out "Terminal.screen: #{JSON.stringify Terminal.screen}"
      Terminal.cursor.x += w_delta
      if Terminal.cursor.x > Terminal.screen.w
        Terminal.cursor.y += Math.floor(Terminal.cursor.x / Terminal.screen.w)
        Terminal.cursor.x = Terminal.cursor.x % Terminal.screen.w
      #Logger.out "cx now #{Terminal.cursor.x}, cy now #{Terminal.cursor.y}"
    process.stdout.write s
    @

  @esc: class # ansi escape sequences
    constructor: (s) -> process.stdout.write "\x1b"+s
    @CLEAR_SCREEN: '[2J'
    @CLEAR_EOL: '[K'
    @CLEAR_EOF: '[J'
    @POS: (x, y) -> "[#{y};#{x}H"
    @color: class
      # modifiers
      @reset       : '[0m'
      @bold        : '[1m'
      @inverse     : '[7m'
      @strike      : '[9m'
      @unbold      : '[22m'
      # foreground
      @black       : '[30m'
      @red         : '[31m'
      @green       : '[32m'
      @yellow      : '[33m'
      @blue        : '[34m'
      @magenta     : '[35m'
      @cyan        : '[36m'
      @white       : '[37m'
      @xterm       : (i) -> "[38;5;#{i}m"
      # background
      @bg_reset    : '[49m'
      @bg_black    : '[40m'
      @bg_red      : '[41m'
      @bg_green    : '[42m'
      @bg_yellow   : '[43m'
      @bg_blue     : '[44m'
      @bg_magenta  : '[45m'
      @bg_cyan     : '[46m'
      @bg_white    : '[47m'
      @bg_xterm     : (i) -> "[48;5;#{i}m"
  @clear: -> Terminal.esc Terminal.esc.CLEAR_SCREEN; @
  @cursor:
    x: null
    y: null
  @screen:
    w: null
    h: null
  @go: (x,y) -> # absolute
    die "Terminal.cursor.x #{x} may not be less than 1!" if x < 1
    die "Terminal.cursor.x #{x} may not be greater than Terminal.screen.w or #{Terminal.screen.w}!" if x > Terminal.screen.w
    Terminal.cursor.x = x
    die "Terminal.cursor.y #{y} may not be less than 1!" if y < 1
    die "Terminal.cursor.y #{y} may not be greater than Terminal.screen.h or #{Terminal.screen.h}!" if y > Terminal.screen.h
    Terminal.cursor.y = y
    Terminal.esc Terminal.esc.POS Terminal.cursor.x, Terminal.cursor.y
    Logger.out "Terminal.cursor = x: #{Terminal.cursor.x}, y: #{Terminal.cursor.y}"
    @
  @move: (x, y=0) -> # relative to current position
    dx = Terminal.cursor.x + x
    dy = Terminal.cursor.y + y
    if dx >= 0 and dx <= Terminal.screen.w and dy >= 0 and dy <= Terminal.screen.h
      @go dx, dy
  @fg: (color) -> Terminal.esc Terminal.esc.color[color]; @
  @bg: (color) -> Terminal.esc Terminal.esc.color['bg_'+color]; @
  @xfg: (i) -> Terminal.esc Terminal.esc.color.xterm i; @
  @xbg: (i) -> Terminal.esc Terminal.esc.color.bg_xterm i; @

  # since some Terminal emulators (like tmux) don't implement
  # things like "erase to end of line"
  # we have to output a bunch of spaces, instead
  # TODO: find out how vim is working normally/smoothly in tmux
  @clear_screen = ->
    Terminal.go(1,1).clear()
    for y in [1..Terminal.screen.h]
      #Terminal.go(1,y)
      Terminal.clear_eol()
    Terminal.go 1, 1; @
  @clear_n = (n) ->
    Terminal.echo repeat n, ' '; @
  @clear_eol = ->
    Terminal.clear_n Terminal.screen.w - Terminal.cursor.x
  @clear_space = (o) ->
    # blank out a rectangle with given bg color
    for y in [o.y...o.y+o.h]
      Terminal.xbg(o.bg).go(o.x, y).clear_n(o.w)
    # set cursor to relative 0,0 of freshly blanked space
    # with given fg color preset
    Terminal.go(o.x, o.y).xbg(o.bg).xfg(o.fg)



