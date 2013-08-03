assert = require('chai').assert
global.logger = out: ->
terminal = require '../precompile/terminal'

describe 'the nvi editor', ->
  it 'can render xterm-256 colors', ->
    terminal.echo "\n "
    # without a space at the beginning of the line,
    # newlines have the background color of the first character on the line
    # until the end of the line. weird!
    for i in [0..255]
      terminal.fg('reset').echo "\n " if (i is 8 or i is 16) or 0 is (i-16) % 36
      terminal.xbg(i).xfg(0).echo(("000"+i).substr(-3)).fg('reset').echo(' ')
    terminal.echo "\n"
