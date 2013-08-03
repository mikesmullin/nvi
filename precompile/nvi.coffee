keypress = require 'keypress'
terminal = require './terminal'
global.logger = require './logger'
global.delay = (s,f) -> setTimeout f, s
global.interval = (s,f) -> setInterval f, s

logger.out '---'
process.stdin.setRawMode true # capture keypress
keypress process.stdin # override keypress event support
keypress.enableMouse process.stdout # override mouse support
#process.stdin.setEncoding 'utf8' # we probably don't care about this right now
die = (err) ->
  process.stdin.resume() # stop waiting for input
  terminal.fg('reset').bg('reset').clear().go(1,1)
  process.stderr.write err+"\n\n" # output the error
  process.exit 1 # exit with non-zero error code
die 'must be in a tty' unless process.stdout.isTTY

# initialize
terminal.screen.w = process.stdout.columns
terminal.screen.h = process.stdout.rows

# misc utils
global.repeat = (n,s) -> o = ''; o += s for i in [0..n]; o

# config
text_fg = 255
text_bg = 235
gutter_bg = 234
gutter_fg = 240

redraw = ->
  terminal.xbg(gutter_bg).clear_screen()
  terminal.xbg(gutter_bg).xfg(gutter_fg).go(1,1).echo('  1 ')
  terminal.xbg(text_bg).xfg(text_fg).echo("how is this?").clear_eol()
  terminal.xbg(gutter_bg).xfg(gutter_fg).echo('  2 ')
  terminal.xbg(text_bg).xfg(text_fg).echo("hehe").clear_eol()
  for y in [terminal.cursor.y..terminal.screen.h]
    terminal.xbg(gutter_bg).xfg(gutter_fg).go(1,y).fg('bold').echo('~').fg('unbold')
  terminal.go(8,2).xfg(255)

redraw()

process.stdout.on 'resize', ->
  # TODO: throttle these events because they can happen rapidly?
  #       only listen to last one in like 500ms
  logger.out "caught resize #{process.stdout.columns}, #{process.stdout.rows}"
  terminal.screen.w = process.stdout.columns
  terminal.screen.h = process.stdout.rows
  redraw()

process.stdin.on 'keypress', (ch, key) ->
  logger.out "got keypress", JSON.stringify arguments
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
    die 'done'

process.stdin.on 'mousepress', (info) ->
  logger.out "caught mousepress: "+ JSON.stringify info
process.on 'exit', ->
  # must return state back to normal for terminal
  keypress.disableMouse process.stdout

process.stdin.resume() # wait for stdin
