module.exports = class Terminal
  # controls writing of all output to the terminal
  @write: (s) -> process.stdout.write s; @
  # offers a system of chaining that lets you
  # build a string in memory, by either:
  @buffer: ''
  # pushing ansi escape codes, or;
  @push_raw: (s) -> Terminal.buffer += s; @
  # pushing human-readable text
  @echo: (s) ->
    if s.length
      # automatically calculate new cursor position
      # by emulating terminal wrapping
      Terminal.cursor.x += s.length
      if Terminal.cursor.x > Terminal.screen.w
        Terminal.cursor.y += Math.floor(Terminal.cursor.x / Terminal.screen.w)
        Terminal.cursor.x = Terminal.cursor.x % Terminal.screen.w
      # also increment y once for every line feed
      s.replace /\n/g, -> Terminal.cursor.y++ # only counts; doesn't actually replace
      Terminal.push_raw s
    return @
  # until you are ready to, either:
  # flush to the terminal, or;
  @flush: ->
    Terminal.write Terminal.buffer
    Terminal.buffer = ''
    @
  # return a string
  @get_clean: ->
    b = Terminal.buffer
    Terminal.buffer = ''
    return b

  @ansi_esc: class # ansi escape sequences
    @cursor_pos   : (x, y) -> "\x1b[#{y};#{x}H"
    @clear_screen : '\x1b[2J'
    @clear_eol    : '\x1b[K' # TODO: why doesn't this work in tmux? its faster/smoother
    @clear_eof    : '\x1b[J'
    @color: class
      # modifiers
      @reset      : '\x1b[0m'
      @bold       : '\x1b[1m'
      @inverse    : '\x1b[7m'
      @strike     : '\x1b[9m'
      @unbold     : '\x1b[22m'
      # foreground
      @black      : '\x1b[30m'
      @red        : '\x1b[31m'
      @green      : '\x1b[32m'
      @yellow     : '\x1b[33m'
      @blue       : '\x1b[34m'
      @magenta    : '\x1b[35m'
      @cyan       : '\x1b[36m'
      @white      : '\x1b[37m'
      @xterm      : (i) -> "\x1b[38;5;#{i}m"
      # background
      @bg_reset   : '\x1b[49m'
      @bg_black   : '\x1b[40m'
      @bg_red     : '\x1b[41m'
      @bg_green   : '\x1b[42m'
      @bg_yellow  : '\x1b[43m'
      @bg_blue    : '\x1b[44m'
      @bg_magenta : '\x1b[45m'
      @bg_cyan    : '\x1b[46m'
      @bg_white   : '\x1b[47m'
      @bg_xterm   : (i) -> "\x1b[48;5;#{i}m"

  @clear: -> Terminal.push_raw Terminal.ansi_esc.clear_screen
  @cursor: x: null, y: null
  @screen: w: null, h: null
  @go: (x,y) -> # absolute
    die "Terminal.cursor.x #{x} may not be less than 1!" if x < 1
    die "Terminal.cursor.x #{x} may not be greater than Terminal.screen.w or #{Terminal.screen.w}!" if x > Terminal.screen.w
    Terminal.cursor.x = x
    die "Terminal.cursor.y #{y} may not be less than 1!" if y < 1
    die "Terminal.cursor.y #{y} may not be greater than Terminal.screen.h or #{Terminal.screen.h}!" if y > Terminal.screen.h
    Terminal.cursor.y = y
    Terminal.push_raw Terminal.ansi_esc.cursor_pos Terminal.cursor.x, Terminal.cursor.y
    Logger.out "Terminal.cursor = x: #{Terminal.cursor.x}, y: #{Terminal.cursor.y}"
    return @
  @move: (x, y=0) -> # relative to current position
    dx = Terminal.cursor.x + x
    dy = Terminal.cursor.y + y
    if dx >= 0 and dx <= Terminal.screen.w and dy >= 0 and dy <= Terminal.screen.h
      @go dx, dy
    return @
  @fg: (color) -> Terminal.push_raw Terminal.ansi_esc.color[color]
  @bg: (color) -> Terminal.push_raw Terminal.ansi_esc.color['bg_'+color]
  @xfg: (i) -> Terminal.push_raw Terminal.ansi_esc.color.xterm i
  @xbg: (i) -> Terminal.push_raw Terminal.ansi_esc.color.bg_xterm i

  # since some Terminal emulators (like tmux) don't implement
  # things like "erase to end of line"
  # we have to output a bunch of spaces, instead
  # TODO: find out how vim is working normally/smoothly in tmux
  @clear_screen = ->
    Terminal.clear()
    for y in [1..Terminal.screen.h]
      Terminal.go 1, y
      Terminal.clear_eol()
    return @
  @clear_n = (n) -> Terminal.echo repeat n, ' '
  @clear_eol = -> Terminal.clear_n Terminal.screen.w - Terminal.cursor.x + 1
  @clear_space = (o) ->
    # blank out a rectangle with given bg color
    for y in [o.y..o.y+o.h-1]
      Terminal.xbg(o.bg).go(o.x, y).clear_n(o.w)
    # set cursor to relative 1,1 of freshly blanked space
    # with given fg color preset
    Terminal.go(o.x, o.y).xbg(o.bg).xfg(o.fg).flush()
    return @
