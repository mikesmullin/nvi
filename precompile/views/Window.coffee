Bar = require './Bar'
Tab = require './Tab'

module.exports = class Window
# has one or more tabs
  constructor: (o) ->
    @file = o?.file
  init: ->
    @x = 1
    @y = 1
    @resize()
    @status_bar = new Bar x: @x, y: @h, w: @w, h: 1, bg: App.config.window_status_bar_bg, fg: App.config.window_status_bar_fg
    @tabs = [new Tab file: @file, x: @x, y: @y, w: @w, h: @ih, active: true] # can never have fewer than one tab
    return
  resize: ->
    App.Logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    App.Terminal.screen.w = process.stdout.columns
    App.Terminal.screen.h = process.stdout.rows
    # the terminal can be as small as it wants
    # but we can't draw a Window in anything smaller than this
    return if App.Terminal.screen.w < 1 or App.Terminal.screen.h < 3
    # outer dimensions
    @w = App.Terminal.screen.w
    @h = App.Terminal.screen.h
    # inner dimensions
    @ih = @h - 1 # make space for status bar
    @iw = @w
    @draw()
    if @status_bar
      @status_bar.resize y: @h, w: @w
    if @tabs
      tab.resize w: @w, h: @ih for tab in @tabs
    return
  draw: ->
    #Terminal.xbg(App.config.view_gutter_bg).clear_screen().flush() # don't need to do this
    return
  current_cursor: ->
    @active_tab?.active_view?.cursors?[0]
