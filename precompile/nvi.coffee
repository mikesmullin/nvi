[nil, nil, filename] = process.argv
keypress = require 'keypress'
global.logger = require './logger'
global.delay = (s,f) -> setTimeout f, s
global.interval = (s,f) -> setInterval f, s
global.repeat = (n,s) -> o = ''; o += s for i in [0..n]; o
global.die = (err) ->
  process.stdin.resume() # stop waiting for input
  terminal.fg('reset').clear().go(1,1)
  if err
    process.stderr.write err+"\n\n" # output the error
    process.exit 1 # exit with non-zero error code
  process.exit 0
  # TODO: how does vim cleanup the scrollback buffer too?
die 'must be in a tty' unless process.stdout.isTTY
global.terminal = require './terminal'
global.config =
  text_fg: 255
  text_bg: 235
  gutter_bg: 234
  gutter_fg: 240
class nvi
  @init: ->
    logger.out 'init'
    process.stdin.setRawMode true # capture keypress
    keypress process.stdin # override keypress event support
    keypress.enableMouse process.stdout # override mouse support
    #process.stdin.setEncoding 'utf8' # we probably don't care about this right now

    process.stdout.on 'resize', resize = (=>
      logger.out "caught resize #{process.stdout.columns}, #{process.stdout.rows}"
      terminal.screen.w = process.stdout.columns
      terminal.screen.h = process.stdout.rows
    ); resize()

    process.stdin.on 'keypress', (ch, key) ->
      logger.out "caught keypress: "+ JSON.stringify arguments
      if key and key.ctrl and key.name is 'c'
        die ''

    process.stdin.on 'mousepress', (info) ->
      logger.out "caught mousepress: "+ JSON.stringify info
    process.on 'exit', ->
      # must return state back to normal for terminal
      keypress.disableMouse process.stdout

    process.stdin.resume() # wait for stdin

nvi.init()
require('./personalize')(nvi)
