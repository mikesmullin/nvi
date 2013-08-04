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
    Window.resize dont_draw: true
    Window.status_bar = new Bar x: 1, y: Window.h, w: Window.w, h: 1, bg: NviConfig.window_status_bar_bg, fg: NviConfig.window_status_bar_fg
    Window.draw()
    Window.tabs = [new Tab file: o?.file, x: Window.x, y: Window.y, w: Window.w, h: Window.ih, active: true] # can never have fewer than one tab
    return
  @resize: (o) ->
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
    Window.draw() unless o?.dont_draw
    Window.status_bar.resize y: Window.h, w: Window.w if Window.status_bar
    return
  @draw: ->
    #Terminal.xbg(NviConfig.view_gutter_bg).clear_screen().flush() # probably don't need to do this
    if Window.tabs
      tab.resize w: Window.w, h: Window.ih for tab in Window.tabs
    return

  @keypress: (ch, key) ->
    Logger.out "caught keypress: "+ JSON.stringify arguments
    code = if ch then ch.charCodeAt 0 else -1

    if Window.mode is 'COMMAND'
      # TODO: get command mode working with resize and redraw()
      if code > 31 and code < 127 # valid command characters
        Window.command_line += ch
        Logger.out "type cmd len #{Window.command_line.length}"
        Terminal.echo(ch).flush()
      else if key.name is 'escape'
        Window.command_line = ''
        Window.command_history_position = 0
        Window.set_mode 'COMBO'
      else if key.name is 'backspace'
        Logger.out "Terminal.cursor.x #{Terminal.cursor.x}"
        if Terminal.cursor.x > 1 and Window.command_line.length > 0
          x = Terminal.cursor.x - 1
          cmd = Window.command_line.substr 0, x-2
          cmd += Window.command_line.substr x-1, Window.command_line.length-x+1
          Window.command_line = cmd
          Logger.out "bksp cmd len #{Window.command_line.length}, cmd #{Window.command_line}"
          Window.status_bar.set_text ':'+cmd
          Terminal.go(x, Terminal.screen.h).flush()
      else if key.name is 'delete'
        return # TODO: finish this WIP
      else if key.name is 'left'
        if Terminal.cursor.x > 2
          Terminal.move(-1).flush()
      else if key.name is 'right'
        if Terminal.cursor.x < Window.command_line.length + 2
          Terminal.move(1).flush()
      else if key.name is 'home'
        Terminal.go(2, Terminal.screen.h).flush()
      else if key.name is 'end'
        Terminal.go(Window.command_line.length+2, Terminal.screen.h).flush()
      else if key.name is 'up'
        1 # retrieve history up matching beginning of current command
      else if key.name is 'down'
        1 # retrieve history down  matching beginning of current command
        # or matching highlighted history command plus any characters typed
        # or else whatever i was typing before this started (skip if tricky)
      else if key.name is 'return'
        Window.execute_cmd Window.command_line
        Window.command_line = ''
        Window.set_mode 'COMBO'

    if Window.mode is 'COMBO'
      switch ch
        when 'i'
          Window.set_mode 'NORMAL'
          return
        when ':'
          Window.mode = 'COMMAND'
          Window.status_bar.set_text ':', false
          return

    if ch is "\u0003" # Ctrl-c
      Window.status_bar.set_text 'Type :quit<Enter> to exit Nvi'
      die '' # for convenience while debugging
      return

    if (Window.mode is 'NORMAL' or Window.mode is 'COMBO') and key
      switch key.name
        when 'escape'
          Window.set_mode 'COMBO'
        when 'left'
          Window.current_cursor().move -1
        when 'right'
          Window.current_cursor().move 1
        when 'up'
          Window.current_cursor().move 0, -1
        when 'down'
          Window.current_cursor().move 0, 1
    return

  @mousepress: (e) ->
    Logger.out "caught mousepress: "+ JSON.stringify e
    return

  @set_mode: (mode) ->
    Window.mode = mode
    Window.status_bar.set_text Terminal
      .xfg(NviConfig.window_mode_fg).fg('bold').echo("-- #{Window.mode} MODE --").fg('unbold')
      .xfg(NviConfig.window_status_bar_fg).get_clean()
    return
  @current_cursor: ->
    Window.active_tab?.active_view?.cursors?[0]
  @execute_cmd: (cmd) ->
    Logger.out "would execute command: #{Window.command_line}"
    Window.command_history.push Window.command_line
    switch cmd
      when 'x', 'wq'
        die ''
      when 'q', 'quit'
        die ''
    return
