keypress = require 'keypress'
terminal = require './terminal'

process.stdin.setRawMode true # capture keypress
keypress process.stdin # override keypress event support
keypress.enableMouse process.stdout # override mouse support
#process.stdin.setEncoding 'utf8' # we probably don't care about this right now
die = (err) ->
  process.stdin.resume() # stop waiting for input
  process.stderr.write err # output the error
  process.exit 1 # exit with non-zero error code
die 'must be in a tty' unless process.stdout.isTTY



process.stdout.on 'resize', ->
  # throttle these events because they can happen rapidly; only listen to last one in like 500ms
  console.log "caught resize #{process.stdout.columns}, #{process.stdout.rows}"

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
  #console.log "got mousepress event at %d x %d", info.x, info.y
  #console.log info
process.on 'exit', ->
  keypress.disableMouse process.stdout # must return state back to normal for terminal


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

for i in [0..255]
  terminal.xbg(i).xfg(i+2).echo(""+i).fg('reset').bg('reset')

terminal.echo "\n"

text_fg = 255
text_bg = 235
gutter_bg = 234
gutter_fg = 240

terminal.echo "\n"
global.delay = (s,f) -> setTimeout f, s
global.interval = (s,f) -> setInterval f, s
terminal.echo "now let's try to clear the screen with gray background\n"
delay 1000, ->
  terminal.xbg(gutter_bg).xfg(gutter_fg).clear().go(1,1).echo('  1 ').xfg(text_fg).xbg(text_bg).echo("how is this?")
  terminal.ctl terminal.ctl.CLEAR_EOL
  terminal.xbg(gutter_bg).xfg(gutter_fg).go(1,2).echo('~   ')
  terminal.ctl terminal.ctl.CLEAR_EOL
  terminal.go(16,1).xfg(255)

process.stdin.resume() # wait for stdin
