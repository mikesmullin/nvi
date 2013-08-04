assert = require('chai').assert
global.Logger = out: ->
global.Terminal = require '../precompile/views/Terminal'

describe 'the nvi editor', ->
  it 'can render xterm-256 colors', ->
    Terminal.echo("\n ").flush()
    # without a space at the beginning of the line,
    # newlines have the background color of the first character on the line
    # until the end of the line. weird!
    for i in [0..255]
      Terminal.fg('reset').echo("\n ").flush() if (i is 8 or i is 16) or 0 is (i-16) % 36
      Terminal.xbg(i).xfg(0).echo(("000"+i).substr(-3)).fg('reset').echo(' ').flush()
    Terminal.echo("\n").flush()
