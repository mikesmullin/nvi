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
  constructor: (o) ->
    @id = o.id # unique string identifier and alias
    @name = o.name # full name
    @email = o.email # email
    @color = o.color # ansi xterm 256-color id
    #@views = []

class Window
# has one or more tabs
  @init: (o) ->
    Window.current_user = o.current_user
    Window.tabs = [new Tab] # can never have fewer than one tab
    Window.h = null # space available for tabs
    Window.resize()
  @resize: ->
    # TODO: throttle event because it does happen rapidly
    #       evaluate just once per ~500ms
    logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    terminal.screen.w = process.stdout.columns
    terminal.screen.h = process.stdout.rows
    Window.h = process.stdout.rows # TODO: can be reduced to make room for tab bar
    tab.resize() for tab in Window.tabs
    Window.draw()
  @keypress: (ch, key) ->
    logger.out "caught keypress: "+ JSON.stringify arguments
    if key and key.ctrl and key.name is 'c'
      die ''
    switch key.name
      when 'left'
        terminal.move -1
      when 'right'
        terminal.move 1
      when 'up'
        terminal.move 0, -1
      when 'down'
        terminal.move 0, 1
  @mousepress: (e) ->
    logger.out "caught mousepress: "+ JSON.stringify e
  @draw: ->
    terminal.xbg(NviConfig.gutter_bg).clear_screen()
    tab.draw() for tab in @tabs

class Tab
# has many views
  constructor: (o) ->
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
    terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(1,1).echo('  1 ')
    terminal.xbg(NviConfig.text_bg).xfg(NviConfig.text_fg).echo("how is this?").clear_eol()
    terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).echo('  2 ')
    terminal.xbg(NviConfig.text_bg).xfg(NviConfig.text_fg).echo("hehe").clear_eol()
    for y in [terminal.cursor.y..terminal.screen.h]
      terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(1,y).fg('bold').echo('~').fg('unbold')
    terminal.go(8,2).xfg(255)

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


logger.out 'init'
Window.init current_user: new User NviConfig.user
process.stdout.on 'resize', Window.resize
process.stdin.on 'keypress', Window.keypress
process.stdin.on 'mousepress', Window.mousepress
