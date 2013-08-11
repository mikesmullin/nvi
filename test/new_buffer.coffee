assert = require('chai').assert
global.repeat = (n,s) -> o = ''; o += s for i in [0...n]; o
{ HydraBuffer, BufferView, BufferViewCursor } = require '../precompile/models/NewBuffer'

options = wrap: true, x: 2, y: 3, w: 82, h: 4, whitespace: tab: "» ", trail: "·", extends: ">", precedes: "<", cr: "\\r"
sample_text = """
Lorem ipsum dolor sit amet,
  consectetur adipiscing elit. Curabitur ut tincidunt lectus.

Morbi posuere enim consequat mauris placerat,   
ut rhoncus risus ullamcorper. Vestibulum feugiat nisl at laoreet pretium. Ut vulputate nulla non diam consectetur tempor. Donec vitae mattis justo,        sed        bibendum nibh.
\tIn non facilisis mauris. Nunc ac condimentum tellus, sit amet feugiat lorem. Curabitur rhoncus fringilla sapien porttitor dignissim.
"""
#sample_text = "abc\ndefgh\r\nijklm\rno\n\r\np\n"

describe 'Buffer WIP', ->
  it 'can parse a string', ->
    buffer = new HydraBuffer options, sample_text
    view = new BufferView buffer
    #console.log buffer.toString()
    #console.log buffer.lines
    console.log buffer.symbols
    console.log view.draw()

describe 'Cursor', ->
  it 'can get a selection', ->
    buffer = new HydraBuffer options, sample_text
    c = new BufferViewCursor buffer: buffer, x: 1, y: 1, w: 1, h: 1
    assert.equal 'L', c.getSelection()
