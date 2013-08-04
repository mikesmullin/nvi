### TODO:
* arrow keys cursor movement
* lclick to place cursor
* lclick+drag to highlight
* double-lclick to highlight word
* triple-lclick to highlight line
###

Tab = require './Tab'

module.exports = class Window
# has one or more tabs
  @init: (o) ->
    Window.current_user = o.current_user
    Window._resize()
    Window.tabs = [new Tab file: o?.file, x: 0, y: 0, w: Window.w, h: Window.h] # can never have fewer than one tab
    Window.active_tab = Window.tabs[0]
    Window.resize()
  @_resize: ->
    Terminal.screen.w = process.stdout.columns
    Terminal.screen.h = process.stdout.rows
    Window.h = Terminal.screen.h # TODO: can be reduced -1 to make room for tab bar
    Window.w = Terminal.screen.w
  @resize: ->
    # TODO: throttle event because it does happen rapidly
    #       evaluate just once per ~500ms
    Logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    Window._resize()
    tab.resize w: Window.w, h: Window.h for tab in Window.tabs
    Window.draw()
  @keypress: (ch, key) ->
    Logger.out "caught keypress: "+ JSON.stringify arguments
    # update screen position of my cursor in terminal
    # TODO: also record (and later broadcast) my cursor position
    #       within the HydraBuffer

    # TODO: on keypress, constrain the cursor's movement to within the area of the view
    # TODO: enforce active focus between views
    # TODO: enforce layout and size between views

    return unless key
    die '' if key.ctrl and key.name is 'c'
    cursor = Window.active_tab.active_view.cursors[0]
    switch key.name
      when 'left'
        cursor.move -1
      when 'right'
        cursor.move 1
      when 'up'
        cursor.move 0, -1
      when 'down'
        cursor.move 0, 1
  @mousepress: (e) ->
    Logger.out "caught mousepress: "+ JSON.stringify e
  @draw: ->
    Terminal.xbg(NviConfig.gutter_bg).clear_screen()
    tab.draw() for tab in @tabs
