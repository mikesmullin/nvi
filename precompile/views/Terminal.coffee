fs = require 'fs'
path = require 'path'
{ repeat } = require '../util'

module.exports = class Terminal
  @ansi_esc: # ansi escape sequences
    cursor_pos   : (x, y) -> "\x1b[#{y};#{x}H"
    clear_screen : '\x1b[2J'
    clear_eol    : '\x1b[K' # TODO: why doesn't this work in tmux? its faster/smoother
    clear_eof    : '\x1b[J'
    color:
      # modifiers
      reset      : '\x1b[0m'
      bold       : '\x1b[1m'
      inverse    : '\x1b[7m'
      strike     : '\x1b[9m'
      unbold     : '\x1b[22m'
      # foreground
      black      : '\x1b[30m'
      red        : '\x1b[31m'
      green      : '\x1b[32m'
      yellow     : '\x1b[33m'
      blue       : '\x1b[34m'
      magenta    : '\x1b[35m'
      cyan       : '\x1b[36m'
      white      : '\x1b[37m'
      xterm      : (i) -> "\x1b[38;5;#{i}m"
      # background
      bg_reset   : '\x1b[49m'
      bg_black   : '\x1b[40m'
      bg_red     : '\x1b[41m'
      bg_green   : '\x1b[42m'
      bg_yellow  : '\x1b[43m'
      bg_blue    : '\x1b[44m'
      bg_magenta : '\x1b[45m'
      bg_cyan    : '\x1b[46m'
      bg_white   : '\x1b[47m'
      bg_xterm   : (i) -> "\x1b[48;5;#{i}m"

  constructor: (o) ->
    @file_head = o?.file_head

  # controls writing of all output to the terminal
  write: (s) ->
    if @file_head # output to file
      fs.appendFileSync path.join(__dirname, '..', '..', @file_head), s
    else # output to screen
      process.stdout.write s
    @
  # offers a system of chaining that lets you
  # build a string in memory, by either:
  buffer: ''
  # pushing ansi escape codes, or;
  push_raw: (s) -> @buffer += s; @
  # pushing human-readable text
  echo: (s) ->
    if s.length
      # automatically calculate new cursor position
      # by emulating terminal wrapping
      @cursor.x += s.length
      if @cursor.x > @screen.w
        @cursor.y += Math.floor(@cursor.x / @screen.w)
        @cursor.x = @cursor.x % @screen.w
      # also increment y once for every line feed
      s.replace /\n/g, -> @cursor.y++ # only counts; doesn't actually replace
      @push_raw s
    return @
  # until you are ready to, either:
  # flush to the terminal, or;
  flush: ->
    @write @buffer
    @buffer = ''
    @
  # return a string
  get_clean: ->
    b = @buffer
    @buffer = ''
    return b

  clear: -> @push_raw Terminal.ansi_esc.clear_screen
  cursor: x: null, y: null
  screen: w: null, h: null
  go: (x,y) -> # absolute
    App.die "@cursor.x #{x} may not be less than 1!" if x < 1
    App.die "@cursor.x #{x} may not be greater than @screen.w or #{@screen.w}!" if x > @screen.w
    @cursor.x = x
    App.die "@cursor.y #{y} may not be less than 1!" if y < 1
    App.die "@cursor.y #{y} may not be greater than @screen.h or #{@screen.h}!" if y > @screen.h
    @cursor.y = y
    @push_raw Terminal.ansi_esc.cursor_pos @cursor.x, @cursor.y
    #Logger.out "@cursor = x: #{@cursor.x}, y: #{@cursor.y}"
    return @
  move: (x, y=0) -> # relative to current position
    dx = @cursor.x + x
    dy = @cursor.y + y
    if dx >= 0 and dx <= @screen.w and dy >= 0 and dy <= @screen.h
      @go dx, dy
    return @
  fg: (color) -> @push_raw Terminal.ansi_esc.color[color]
  bg: (color) -> @push_raw Terminal.ansi_esc.color['bg_'+color]
  xfg: (i) -> @push_raw Terminal.ansi_esc.color.xterm i
  xbg: (i) -> @push_raw Terminal.ansi_esc.color.bg_xterm i

  # since some Terminal emulators (like tmux) don't implement
  # things like "erase to end of line"
  # we have to output a bunch of spaces, instead
  # TODO: find out how vim is working normally/smoothly in tmux
  clear_screen: ->
    @clear()
    for y in [1..@screen.h]
      @go 1, y
      @clear_eol()
    return @
  clear_n: (n) -> @echo repeat n, ' '
  clear_eol: -> @clear_n @screen.w - @cursor.x + 1
  clear_space: (o) ->
    # blank out a rectangle with given bg color
    for y in [o.y..o.y+o.h-1]
      @xbg(o.bg).go(o.x, y).clear_n(o.w)
    # set cursor to relative 1,1 of freshly blanked space
    # with given fg color preset
    @go(o.x, o.y).xbg(o.bg).xfg(o.fg).flush()
    return @
