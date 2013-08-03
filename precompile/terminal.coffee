module.exports = class terminal
  @echo: (s) ->
    w_delta = s.length
    if w_delta
      s.replace(/[\r\n]+/, -> terminal.cursor.y++; '') # only counts newlines
      logger.out "cx was #{terminal.cursor.x}, cy was #{terminal.cursor.y}"
      logger.out "s.length #{w_delta} s=\"#{s}\""
      terminal.cursor.x += w_delta
      if terminal.cursor.x > terminal.screen.w
        terminal.cursor.y += Math.floor(terminal.cursor.x / terminal.screen.w)
        terminal.cursor.x = terminal.cursor.x % terminal.screen.w
      logger.out "cx now #{terminal.cursor.x}, cy now #{terminal.cursor.y}"
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
  @clear: -> terminal.esc terminal.esc.CLEAR_SCREEN; @
  @cursor:
    x: null
    y: null
  @screen:
    w: null
    h: null
  @go: (x,y) ->
    terminal.cursor.x = x
    terminal.cursor.y = y
    terminal.esc terminal.esc.POS x, y; @
  @fg: (color) -> terminal.esc terminal.esc.color[color]; @
  @bg: (color) -> terminal.esc terminal.esc.color['bg_'+color]; @
  @xfg: (i) -> terminal.esc terminal.esc.color.xterm i; @
  @xbg: (i) -> terminal.esc terminal.esc.color.bg_xterm i; @

  # since some terminal emulators (like tmux) don't implement
  # things like "erase to end of line"
  # we have to output a bunch of spaces, instead
  @clear_screen = ->
    terminal.go(1,1).clear()
    for y in [0..terminal.screen.h]
      #terminal.go(1,y)
      terminal.clear_eol()
    terminal.go 1, 1; @
  @clear_eol = ->
    terminal.echo repeat terminal.screen.w - terminal.cursor.x, ' '; @
