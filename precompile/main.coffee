global.NviConfig = require '../config.json'
global.Logger = require './Logger'
global.Terminal = require './Terminal'
global.delay = (s,f) -> setTimeout f, s
global.interval = (s,f) -> setInterval f, s
global.repeat = (n,s) -> o = ''; o += s for i in [0..n]; o
global.die = (err) ->
  process.stdin.resume() # stop waiting for input
  Terminal.fg('reset').clear().go(1,1)
  if err
    process.stderr.write err+"\n\n" # output the error
    process.exit 1 # exit with non-zero error code
  process.exit 0
  # TODO: how does vim cleanup the scrollback buffer too?
die 'must be in a tty' unless process.stdout.isTTY

keypress = require 'keypress'
process.stdin.setRawMode true # capture keypress
keypress process.stdin # override keypress event support
keypress.enableMouse process.stdout # override mouse support
process.on 'exit', -> keypress.disableMouse process.stdout # return to normal for terminal
process.stdin.setEncoding 'utf8' # modern times

[nil, nil, filename] = process.argv
User = require './User'
Window = require './Window'

Logger.out 'init'
Window.init current_user: new User NviConfig.user
process.stdout.on 'resize', Window.resize
process.stdin.on 'keypress', Window.keypress
process.stdin.on 'mousepress', Window.mousepress

process.stdin.resume() # wait for stdin
