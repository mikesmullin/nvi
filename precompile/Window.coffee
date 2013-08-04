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
    Window.resize()
    Window.tabs = [new Tab file: o?.file, x: 1, y: 1, w: Window.w, h: Window.ih, active: true] # can never have fewer than one tab
    # COMBO, NORMAL, REPLACE, BLOCK, LINE-BLOCK, COMMAND
    Window.mode = 'COMBO'
    Window.command_line = ''
    Window.command_history = []
    Window.command_history_position = 0
  @resize: ->
    Logger.out "window caught resize #{process.stdout.columns}, #{process.stdout.rows}"
    Terminal.screen.w = process.stdout.columns
    Terminal.screen.h = process.stdout.rows
    #Window.x = 0 # can be safely assumed
    #Window.y = 0
    Window.w = Terminal.screen.w
    die "Window.w may not be less than 1!" if Window.w < 1
    # outer height
    Window.h = Terminal.screen.h
    die "Window.h may not be less than 3!" if Window.h < 3
    # inner height (after decorators like status bar)
    Window.ih = Window.h - 1
    Window.draw()
    tab.resize w: Window.w, h: Window.ih for tab in Window.tabs
  @draw: ->
    Terminal.xbg(NviConfig.gutter_bg).clear_screen()
    Window.clear_status_bar()
  @keypress: (ch, key) ->
    Logger.out "caught keypress: "+ JSON.stringify arguments
    code = if ch then ch.charCodeAt 0 else -1

    if Window.mode is 'COMMAND'
      # TODO: get command mode working with resize and redraw()
      if code > 31 and code < 127 # valid command characters
        Window.command_line += ch
        Logger.out "type cmd len #{Window.command_line.length}"
        Terminal.echo ch
      else if key.name is 'escape'
        Window.change_mode 'COMBO'
      else if key.name is 'backspace'
        Logger.out "Terminal.cursor.x #{Terminal.cursor.x}"
        if Terminal.cursor.x > 1 and Window.command_line.length > 0
          x = Terminal.cursor.x - 1
          cmd = Window.command_line.substr 0, x-2
          cmd += Window.command_line.substr x-1, Window.command_line.length-x+1
          Window.command_line = cmd
          Logger.out "bksp cmd len #{Window.command_line.length}, cmd #{Window.command_line}"
          Window.set_status ':'+cmd
          Terminal.go x, Terminal.screen.h
      else if key.name is 'left'
        if Terminal.cursor.x > 2
          Terminal.move -1
      else if key.name is 'right'
        if Terminal.cursor.x < Window.command_line.length + 2
          Terminal.move 1
      else if key.name is 'home'
        Terminal.go 2, Terminal.screen.h
      else if key.name is 'end'
        Terminal.go Window.command_line.length+2, Terminal.screen.h
      else if key.name is 'up'
        1 # retrieve history up matching beginning of current command
      else if key.name is 'down'
        1 # retrieve history down  matching beginning of current command
        # or matching highlighted history command plus any characters typed
        # or else whatever i was typing before this started (skip if tricky)
      else if key.name is 'return'
        Window.execute_cmd Window.command_line
        Window.command_line = ''
        Window.change_mode 'COMBO'

    if Window.mode is 'COMBO'
      switch ch
        when 'i'
          Window.change_mode 'NORMAL'
          return
        when ':'
          Window.mode = 'COMMAND'
          Window.clear_status_bar()
          Terminal.echo(':')
          return

    if ch is "\u0003" # Ctrl-c
      Window.set_status 'Type :quit<Enter> to exit Nvi'
      die '' # for convenience while debugging
      #return

    if (Window.mode is 'NORMAL' or Window.mode is 'COMBO') and key
      switch key.name
        when 'escape'
          Window.change_mode 'COMBO'
        when 'left'
          Window.current_cursor().move -1
        when 'right'
          Window.current_cursor().move 1
        when 'up'
          Window.current_cursor().move 0, -1
        when 'down'
          Window.current_cursor().move 0, 1

  @execute_cmd: (cmd) ->
    Logger.out "would execute command: #{Window.command_line}"
    Window.command_history.push Window.command_line
    switch cmd
      when 'x', 'wq'
        die ''
      when 'q', 'quit'
        die ''

  @mousepress: (e) ->
    Logger.out "caught mousepress: "+ JSON.stringify e
  @change_mode: (mode) ->
    Window.mode = mode
    Window.clear_status_bar()
    # TODO: make it so i can pass color codes to Window.set_status()
    Terminal.xfg(NviConfig.mode_fg).fg('bold').echo("-- #{Window.mode} MODE --").fg('unbold').xfg(NviConfig.status_bar_fg).clear_eol()
    Window.current_cursor().move 0 # return cursor to last position
  @current_cursor: ->
    Window.active_tab?.active_view?.cursors?[0]
  @set_status: (s) ->
    Window.clear_status_bar()
    Terminal.echo(s.substr(0, Window.w)).clear_eol()
    Window.current_cursor().move 0 # return cursor to last position
  @clear_status_bar: ->
    Terminal.clear_space bg: NviConfig.status_bar_bg, fg: NviConfig.status_bar_fg, x: 1, y: Window.h, w: Window.w, h: 1
