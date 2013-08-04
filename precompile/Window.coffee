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
    Window.tabs = [new Tab] # can never have fewer than one tab
    Window.active_tab = Window.tabs[0]
    Window.h = null # space available for tabs
    Window.resize()
  @resize: ->
    # TODO: throttle event because it does happen rapidly
    #       evaluate just once per ~500ms
    Logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    Terminal.screen.w = process.stdout.columns
    Terminal.screen.h = process.stdout.rows
    Window.h = process.stdout.rows # TODO: can be reduced to make room for tab bar
    tab.resize() for tab in Window.tabs
    Window.draw()
  @keypress: (ch, key) ->
    Logger.out "caught keypress: "+ JSON.stringify arguments
    # update screen position of my cursor in terminal
    # TODO: also record (and later broadcast) my cursor position
    #       within the HydraBuffer
    Window.active_tab.active_view.cursors[0] # my_cursor
    if key and key.ctrl and key.name is 'c'
      die ''
    switch key.name
      when 'left'
        Terminal.move -1
      when 'right'
        Terminal.move 1
      when 'up'
        Terminal.move 0, -1
      when 'down'
        Terminal.move 0, 1
  @mousepress: (e) ->
    Logger.out "caught mousepress: "+ JSON.stringify e
  @draw: ->
    Terminal.xbg(NviConfig.gutter_bg).clear_screen()
    tab.draw() for tab in @tabs
