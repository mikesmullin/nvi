Bar = require './Bar'
Tab = require './Tab'

module.exports = class Window
# has one or more tabs
  @init: (o) ->
    Window.current_user = o.current_user
    # valid options: NORMAL, COMBO, REPLACE, BLOCK, LINE-BLOCK, COMMAND
    Window.mode = 'NORMAL' # always begin in this mode
    Window.command_line = ''
    Window.command_history = []
    Window.command_history_position = 0
    Window.x = 1
    Window.y = 1
    Window.resize()
    Window.status_bar = new Bar x: Window.x, y: Window.h, w: Window.w, h: 1, bg: NviConfig.window_status_bar_bg, fg: NviConfig.window_status_bar_fg
    Window.tabs = [new Tab file: o?.file, x: Window.x, y: Window.y, w: Window.w, h: Window.ih, active: true] # can never have fewer than one tab
    return
  @resize: ->
    Logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    Terminal.screen.w = process.stdout.columns
    Terminal.screen.h = process.stdout.rows
    # the terminal can be as small as it wants
    # but we can't draw a Window in anything smaller than this
    return if Terminal.screen.w < 1 or Terminal.screen.h < 3
    # outer dimensions
    Window.w = Terminal.screen.w
    Window.h = Terminal.screen.h
    # inner dimensions
    Window.ih = Window.h - 1 # make space for status bar
    Window.iw = Window.w
    Window.draw()
    if Window.status_bar
      Window.status_bar.resize y: Window.h, w: Window.w
    if Window.tabs
      tab.resize w: Window.w, h: Window.ih for tab in Window.tabs
    return
  @draw: ->
    #Terminal.xbg(NviConfig.view_gutter_bg).clear_screen().flush() # don't need to do this
    return
  @set_mode: (mode) ->
    Window.mode = mode
    Window.status_bar.set_text Terminal
      .xfg(NviConfig.window_mode_fg).fg('bold').echo("-- #{Window.mode} MODE --").fg('unbold')
      .xfg(NviConfig.window_status_bar_fg).get_clean()
    return
  @current_cursor: ->
    Window.active_tab.active_view.cursors[0]
