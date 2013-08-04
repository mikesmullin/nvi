### TODO:
* mode toggle
* status bar
* arrow keys cursor movement constrained by view text depending on mode
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
    Window.tabs = []
    Window._resize()
    Window.draw()
    Window.tabs = [new Tab file: o?.file, x: 0, y: 0, w: Window.w, h: Window.h, active: true] # can never have fewer than one tab
    # COMBO, NORMAL, REPLACE, BLOCK, LINE-BLOCK
    Window.mode = 'COMBO'
  @_resize: ->
    Terminal.screen.w = process.stdout.columns
    Terminal.screen.h = process.stdout.rows
    Window.h = Terminal.screen.h - 1 # make room for status bar
    Window.w = Terminal.screen.w
  @resize: ->
    # TODO: throttle event because it does happen rapidly
    #       evaluate just once per ~500ms
    Logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    Window._resize()
    Window.draw()
    tab.resize w: Window.w, h: Window.h for tab in Window.tabs
  @draw: ->
    Terminal.xbg(NviConfig.gutter_bg).clear_screen()
    Window.clear_status_bar()
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
    switch key.name
      when 'escape'
        1
        #@move_to_status_bar()
      when 'left'
        Window.current_cursor().move -1
      when 'right'
        Window.current_cursor().move 1
      when 'up'
        Window.current_cursor().move 0, -1
      when 'down'
        Window.current_cursor().move 0, 1
  @mousepress: (e) ->
    Logger.out "caught mousepress: "+ JSON.stringify e
  @current_cursor: ->
    Window.active_tab?.active_view?.cursors?[0]
  @set_status: (s) ->
    Window.clear_status_bar()
    Window.move_to_status_bar()
    Terminal.echo(s.substr(0, Terminal.screen.w)).clear_eol()
    Window.current_cursor().move 0 # return cursor to last position
  @clear_status_bar: ->
    Terminal.xbg(NviConfig.status_bar_bg).go(1, Terminal.screen.h).clear_eol()
  @move_to_status_bar: ->
    Terminal.go(1, Terminal.screen.h).xbg(NviConfig.status_bar_bg).xfg(NviConfig.status_bar_fg)
