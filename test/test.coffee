assert = require('chai').assert
global.logger = out: ->
terminal = require '../precompile/terminal'

describe 'the nvi editor', ->
  it 'can render xterm-256 colors', ->
    terminal.echo "\n"
    for i in [0..255]
      terminal.echo "\n" if (i is 8 or i is 16) or 0 is (i-16) % 36
      terminal.xbg(i).xfg(0).echo(("000"+i).substr(-3)).fg('reset').bg('reset').echo(' ')
