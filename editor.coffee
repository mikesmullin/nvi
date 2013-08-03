#tty = require 'tty'
process.stdin.setRawMode true # emit events on keystroke

keypress = require 'keypress'
keypress process.stdin # make process.stdin emit keypress events
keypress.enableMouse process.stdout
process.stdin.on 'keypress', (ch, key) ->
  console.log "got keypress", arguments
  # got keypress { '0': 'a',
  #   '1':
  #    { name: 'a',
  #      ctrl: false,
  #      meta: false,
  #      shift: false,
  #      sequence: 'a' } }
  # got keypress { '0': 'A',
  #   '1': { name: 'a', ctrl: false, meta: false, shift: true, sequence: 'A' } }
  # got keypress { '0': '\u0001',
  #   '1':
  #    { name: 'a',
  #      ctrl: true,
  #      meta: false,
  #      shift: false,
  #      sequence: '\u0001' } }
  # got keypress { '0': undefined,
  #   '1':
  #    { name: 'a',
  #      ctrl: false,
  #      meta: true,
  #      shift: false,
  #      sequence: '\u001ba' } }
  # got keypress { '0': 'a',
  #   '1':
  #    { name: 'a',
  #      ctrl: false,
  #      meta: false,
  #      shift: false,
  #      sequence: 'a' } }
  if key and key.ctrl and key.name is 'c'
    process.stdin.pause()
process.stdin.on 'mousepress', (info) ->
  console.log "got mousepress event at %d x %d", info.x, info.y
  console.log info
process.on 'exit', ->
  keypress.disableMouse process.stdout # must return state back to normal for terminal

process.stdin.setEncoding 'utf8' # may not be necessary
process.stdin.resume() # begin reading from stdin; also holds node process open

if process.stdout.isTTY
  console.log "we are in a TTY!"
  console.log "the dims are: cols=#{process.stdout.columns}, rows=#{process.stdout.rows}"
  process.stdout.on 'resize', ->
    # throttle these events because they can happen rapidly; only listen to last one in like 500ms
    console.log 'you just resized!'
    console.log "the dims are: cols=#{process.stdout.columns}, rows=#{process.stdout.rows}"

console.log "watch! this is going to become like vim! :)"

class ctl # ansi escape sequences / control characters/codes
  constructor: (s) -> terminal.echo "\u001b"+s
  @CLEAR: '[2J'
  @POS: (x, y) -> "[#{y};#{x}H"
  @color: class
    # modifiers
    @bold        : '[1m'
    # foreground
    @reset       : '[0m'
    @black       : '[30m'
    @red         : '[31m'
    @green       : '[32m'
    @yellow      : '[33m'
    @blue        : '[34m'
    @magenta     : '[35m'
    @cyan        : '[36m'
    @white       : '[37m'
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

class terminal
  @echo: (s) -> process.stdout.write s; @
  @clear: -> ctl ctl.CLEAR; @
  @go: (x,y) -> ctl ctl.POS x, y; @
  @fg: (color) -> ctl ctl.color[color]; @
  @bg: (color) -> ctl ctl.color['bg_'+color]; @

terminal.clear().go(0,0).echo "hello curses world!\n"

for layer in ['', 'bg_']
  for bold in [0, 1]
    terminal.echo "\n"
    for color in 'black red green yellow blue magenta cyan white'.split ' '
      color_name = "#{layer}#{color}"
      terminal.fg('bold') if bold
      if layer is ''
        terminal.fg(color).echo(color_name).fg('reset')
      else
        terminal.bg(color).fg('white').echo(color_name).bg('reset')

terminal.echo "\n"
