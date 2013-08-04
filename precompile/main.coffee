# TODO: move these all out of the global namespace
#       pass them via instantiation like teacup
#       and move utility functions into something like Underscore _
global.NviConfig = require '../config.json'
global.Logger = require './models/Logger'
global.Terminal = require './views/Terminal'
global.delay = (s,f) -> setTimeout f, s
global.interval = (s,f) -> setInterval f, s
global.repeat = (n,s) -> o = ''; o += s for i in [0...n]; o
#global._throttles = {}
#global.throttle = (ms, k, f) -> ->
#  return if _throttles[k]
#  _throttles[k] = true
#  delay ms, -> delete _throttles[k]
#  f.apply null, arguments

cleaned_up = false
cleanup = ->
  return if cleaned_up
  process.stdin.pause() # stop waiting for input
  Terminal.fg('reset').clear().go(1,1).flush()
  cleaned_up = true
process.on 'exit', cleanup
global.die = (err) ->
  cleanup()
  if err
    process.stderr.write err+"\n" # output the error
    console.trace() # with a backtrace
    process.exit 1 # exit with non-zero error code
  process.stdout.write "see you soon!\n"
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
User = require './models/User'
global.Window = require './views/Window'

Logger.out 'init'
Window.init
  current_user: new User NviConfig.user
  file: filename
process.stdout.on 'resize', Window.resize
process.stdin.on 'keypress', Window.keypress
process.stdin.on 'mousepress', Window.mousepress

process.stdin.resume() # wait for stdin
