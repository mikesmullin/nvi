module.exports = class Application
  @init: (o) ->
    Application.current_user = o.current_user
    # valid options: NORMAL, COMBO, REPLACE, BLOCK, LINE-BLOCK, COMMAND
    Application.mode = 'NORMAL' # always begin in this mode
    Application.command_line = ''
    Application.command_history = []
    Application.command_history_position = 0

  @keypress: (ch, key) ->
    Logger.out "caught keypress: "+ JSON.stringify arguments
    code = if ch then ch.charCodeAt 0 else -1

    if Application.mode is 'COMMAND'
      # TODO: get command mode working with resize and redraw()
      if code > 31 and code < 127 # valid command characters
        Application.command_line += ch
        Logger.out "type cmd len #{Application.command_line.length}"
        Terminal.echo(ch).flush()
      else if key.name is 'escape'
        Application.command_line = ''
        Application.command_history_position = 0
        Application.set_mode 'COMBO'
      else if key.name is 'backspace'
        Logger.out "Terminal.cursor.x #{Terminal.cursor.x}"
        if Terminal.cursor.x > 1 and Application.command_line.length > 0
          x = Terminal.cursor.x - 1
          cmd = Application.command_line.substr 0, x-2
          cmd += Application.command_line.substr x-1, Application.command_line.length-x+1
          Application.command_line = cmd
          Logger.out "bksp cmd len #{Application.command_line.length}, cmd #{Application.command_line}"
          Window.status_bar.set_text ':'+cmd
          Terminal.go(x, Terminal.screen.h).flush()
      else if key.name is 'delete'
        return # TODO: finish this WIP
      else if key.name is 'left'
        if Terminal.cursor.x > 2
          Terminal.move(-1).flush()
      else if key.name is 'right'
        if Terminal.cursor.x < Application.command_line.length + 2
          Terminal.move(1).flush()
      else if key.name is 'home'
        Terminal.go(2, Terminal.screen.h).flush()
      else if key.name is 'end'
        Terminal.go(Application.command_line.length+2, Terminal.screen.h).flush()
      else if key.name is 'up'
        1 # retrieve history up matching beginning of current command
      else if key.name is 'down'
        1 # retrieve history down  matching beginning of current command
        # or matching highlighted history command plus any characters typed
        # or else whatever i was typing before this started (skip if tricky)
      else if key.name is 'return'
        Application.execute_cmd Application.command_line
        Application.command_line = ''
        Application.set_mode 'COMBO'

    if Application.mode is 'COMBO'
      switch ch
        when 'i'
          Application.set_mode 'NORMAL'
          return
        when ':'
          Application.mode = 'COMMAND'
          Window.status_bar.set_text ':', false
          return

    if ch is "\u0003" # Ctrl-c
      Window.status_bar.set_text 'Type :quit<Enter> to exit Nvi'
      die '' # for convenience while debugging
      return

    if (Application.mode is 'NORMAL' or Application.mode is 'COMBO') and key
      switch key.name
        when 'escape'
          Application.set_mode 'COMBO'
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
    Application.mode = mode
    Window.status_bar.set_text Terminal
      .xfg(NviConfig.window_mode_fg).fg('bold').echo("-- #{Application.mode} MODE --").fg('unbold')
      .xfg(NviConfig.window_status_bar_fg).get_clean()
    return

  @execute_cmd: (cmd) ->
    Logger.out "would execute command: #{Application.command_line}"
    Application.command_history.push Application.command_line
    args = cmd.split ' '
    switch args[0]
      when 'x', 'wq'
        die ''
      when 'q', 'quit'
        die ''
      when 'vsplit', 'hsplit', 'split'
        return Window.active_tab.split args[0], args[1]
