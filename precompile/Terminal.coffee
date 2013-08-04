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
  @buffer:
    w: null
    h: 2
  @go: (x,y) ->
    Terminal.cursor.x = x
    Terminal.cursor.y = y
    Terminal.esc Terminal.esc.POS x, y
    #Logger.out "cursor now #{x}, #{y}"
    @
  @move: (x, y=0) ->
    dx = Terminal.cursor.x + x
    dy = Terminal.cursor.y + y
    if dx > 4 and dx < Terminal.screen.w and dy > 0 and dy <= Terminal.buffer.h
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
    for y in [0..Terminal.screen.h]
      #Terminal.go(1,y)
      Terminal.clear_eol()
    Terminal.go 1, 1; @
  @clear_eol = ->
    Terminal.echo repeat Terminal.screen.w - Terminal.cursor.x, ' '; @
