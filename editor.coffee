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
    @reset:          "[0m"
    @black:          "[30m"
    @red:            "[31m"
    @green:          "[32m"
    @yellow:         "[33m"
    @blue:           "[34m"
    @magenta:        "[35m"
    @cyan:           "[36m"
    @white:          "[37m"
    @grey:           "[1m\u001b[30m"
    @bright_red:     "[1m\u001b[31m"
    @bright_green:   "[1m\u001b[32m"
    @bright_yellow:  "[1m\u001b[33m"
    @bright_blue:    "[1m\u001b[34m"
    @bright_magenta: "[1m\u001b[35m"
    @bright_cyan:    "[1m\u001b[36m"
    @bright_white:   "[1m\u001b[37m"

class terminal
  @echo: (s) -> process.stdout.write s; @
  @reset: -> ctl ctl.CLEAR; @
  @go: (x,y) -> ctl ctl.POS x, y; @
  @fg: (color) -> ctl ctl.color[color]; @

terminal.reset().go(0,0).echo "hello curses world!\n"

for prefix in ['', 'bright_']
  for suffix in 'black red green yellow blue magenta cyan white grey'.split ' '
    color = prefix+suffix
    if ctl.color[color]?
      terminal.fg(color).echo color

terminal.echo "\n"
