### TODO:
* arrow keys cursor movement
* lclick to place cursor
* lclick+drag to highlight
* double-lclick to highlight word
* triple-lclick to highlight line
###
fs = require 'fs'

class User
# has one or more views
  constructor: ->
    @id = '' # unique string identifier and alias
    @name = '' # full name
    @email = '' # email
    @color = null # ansi xterm 256-color id
    @views = []

class Cursor
# belong to a user
# belong to a hydrabuffer
# cursors can also highlight and block edit
  constructor: ->
    @user = new User # by reference
    @view = View # by reference
    @x = null
    @y = null
    @w = 1
    @h = 1

class HydraBuffer
# belong to one or more views
# one per buffer
# has one or more cursors
  constructor: ->
    @view = View # by reference
    @buffer = Buffer
    @cursors = [] # array of Cursors
  @from_file: (filename) ->
    fs.open filename, 'r', (err, fd) ->
      buffer = new Buffer 100
      fs.read fd, buffer, 0, buffer.length, 0, (err, bytesRead, buffer) ->
        b.toString 'utf8'

class Window
# has one or more tabs
  @init: (nvi) ->
    @tabs = [new Tab window: @] # can never have fewer than one tab
    process.stdout.on 'resize', Window.resize
    Window.resize()
  @resize: ->
    # TODO: throttle event because it does happen rapidly
    #       evaluate just once per ~500ms
    # space available for tabs
    @h = process.stdout.rows # can be reduced to make room for tab bar
    tab.resize() for tab in @tabs
    Window.draw()
  @draw: ->
    terminal.xbg(config.gutter_bg).clear_screen()
    tab.draw() for tab in @tabs

class Tab
# has many views
  constructor: (o) ->
    @window = o.window
    @name = o?.name or 'untitled'
    @views = [new View tab: @] # can never have fewer than one view
  resize: ->
    view.resize() for view in @views
    @draw()
  draw: ->
    # if draw_tab_bar
    view.draw() for view in @views

class View
# belong to a user
# has one hydrabuffer
# renders both text and cursors from hydrabuffers
# redraws its section of real-estate on-screen
# the treeview is a view, too with an option set for curline_bg
  constructor: (o) ->
    @tab = o.tab
    @hydrabuffer = HydraBuffer
    @user = User
    @w = null
    @h = null
    @offset = null
  resize: ->
    @draw()
  draw: ->
    terminal.xbg(config.gutter_bg).xfg(config.gutter_fg).go(1,1).echo('  1 ')
    terminal.xbg(config.text_bg).xfg(config.text_fg).echo("how is this?").clear_eol()
    terminal.xbg(config.gutter_bg).xfg(config.gutter_fg).echo('  2 ')
    terminal.xbg(config.text_bg).xfg(config.text_fg).echo("hehe").clear_eol()
    for y in [terminal.cursor.y..terminal.screen.h]
      terminal.xbg(config.gutter_bg).xfg(config.gutter_fg).go(1,y).fg('bold').echo('~').fg('unbold')
    terminal.go(8,2).xfg(255)



module.exports = (nvi) ->
  logger.out 'will personalize'

  Window.init nvi

  process.stdin.on 'keypress', (ch, key) =>
    switch key.name
      when 'left'
        terminal.move -1
      when 'right'
        terminal.move 1
      when 'up'
        terminal.move 0, -1
      when 'down'
        terminal.move 0, 1


