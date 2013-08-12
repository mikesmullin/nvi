Logger = require '../models/Logger'
User = require '../models/User'
Terminal = require '../views/Terminal'
Window = require '../views/Window'

module.exports = class Application
  constructor: (o) ->
    @config = require '../../config.json'
    @Logger = new Logger filename: @config.log_file
    @Logger.out 'init'
    # valid options: NORMAL, COMBO, REPLACE, BLOCK, LINE-BLOCK, COMMAND
    @mode = 'NORMAL' # always begin in this mode
    @command_line = ''
    @command_history = []
    @command_history_position = 0
    @current_user = new User @config.user
    @Terminal = new Terminal
      file_head: o.headless_display_file or @config.headless_display_file
    @Window = new Window file: o?.args?[0]
    unless o.headless_tty_file
      @die 'must be in a tty' unless process.stdout.isTTY
      keypress = require 'keypress'
      process.stdin.setRawMode true # capture keypress
      keypress process.stdin # override keypress event support
      keypress.enableMouse process.stdout # override mouse support
      process.on 'exit', -> keypress.disableMouse process.stdout # return to normal for terminal
      process.stdin.setEncoding 'utf8' # modern times
      process.stdout.on 'resize', @Window.resize
      process.stdin.on 'keypress', @keypress
      process.stdin.on 'mousepress', @mousepress
      process.stdin.resume() # wait for stdin
      process.on 'exit', @destroy
  init: ->
    @Window.init()
  destroy: (o) =>
    return if @destroyed
    @destroyed = true
    process.stdout.removeListener 'resize', @Window.resize
    process.stdin.removeListener 'keypress', @keypress
    process.stdin.removeListener 'mousepress', @mousepress
    process.stdin.pause() # stop waiting for input
    unless o?.dont_clear
      @Terminal.fg('reset').clear().go(1,1).flush()
  die: (err) ->
    @destroy()
    if err
      process.stderr.write err+"\n" # output the error
      console.trace() # with a backtrace
      process.exit 1 # exit with non-zero error code
    process.stdout.write "see you soon!\n"
    process.exit 0
    # TODO: how does vim cleanup the scrollback buffer too?

  keypress: (ch, key) =>
    @Logger.out "caught keypress: "+ JSON.stringify arguments
    code = if ch then ch.charCodeAt 0 else -1

    if @mode is 'COMMAND'
      # TODO: get command mode working with resize and redraw()
      if code > 31 and code < 127 # valid command characters
        @command_line += ch
        @Logger.out "type cmd len #{@command_line.length}"
        @Terminal.echo(ch).flush()
      else if key.name is 'escape'
        @command_line = ''
        @command_history_position = 0
        @set_mode 'COMBO'
      else if key.name is 'backspace'
        @Logger.out "Terminal.cursor.x #{@Terminal.cursor.x}"
        if @Terminal.cursor.x > 1 and @command_line.length > 0
          x = @Terminal.cursor.x - 1
          cmd = @command_line.substr 0, x-2
          cmd += @command_line.substr x-1, @command_line.length-x+1
          @command_line = cmd
          @Logger.out "bksp cmd len #{@command_line.length}, cmd #{@command_line}"
          @Window.status_bar.set_text ':'+cmd
          @Terminal.go(x, @Terminal.screen.h).flush()
      else if key.name is 'delete'
        return # TODO: finish this WIP
      else if key.name is 'left'
        if @Terminal.cursor.x > 2
          @Terminal.move(-1).flush()
      else if key.name is 'right'
        if @Terminal.cursor.x < @command_line.length + 2
          @Terminal.move(1).flush()
      else if key.name is 'home'
        @Terminal.go(2, @Terminal.screen.h).flush()
      else if key.name is 'end'
        @Terminal.go(@command_line.length+2, @Terminal.screen.h).flush()
      else if key.name is 'up'
        1 # retrieve history up matching beginning of current command
      else if key.name is 'down'
        1 # retrieve history down  matching beginning of current command
        # or matching highlighted history command plus any characters typed
        # or else whatever i was typing before this started (skip if tricky)
      else if key.name is 'return'
        @execute_cmd @command_line
        @command_line = ''
        @set_mode 'COMBO'

    if @mode is 'COMBO'
      switch ch
        when 'i'
          @set_mode 'NORMAL'
          return
        when ':'
          @mode = 'COMMAND'
          @Window.status_bar.set_text ':', false
          return

    if ch is "\u0003" # Ctrl-c
      @Window.status_bar.set_text 'Type :quit<Enter> to exit Nvi'
      @die '' # for convenience while debugging
      return

    if (@mode is 'NORMAL' or @mode is 'COMBO') and key
      switch key.name
        when 'escape'
          @set_mode 'COMBO'
        when 'left'
          @Window.current_cursor().move -1
        when 'right'
          @Window.current_cursor().move 1
        when 'up'
          @Window.current_cursor().move 0, -1
        when 'down'
          @Window.current_cursor().move 0, 1
    return

  mousepress: (e) =>
    @Logger.out "caught mousepress: "+ JSON.stringify e
    return

  set_mode: (mode) ->
    @mode = mode
    @Window.status_bar.set_text @Terminal
      .xfg(@config.window_mode_fg).fg('bold').echo("-- #{@mode} MODE --").fg('unbold')
      .xfg(@config.window_status_bar_fg).get_clean()
    return

  execute_cmd: (cmd) ->
    @Logger.out "would execute command: #{@command_line}"
    @command_history.push @command_line
    args = cmd.split ' '
    switch args[0]
      when 'x', 'wq'
        @die ''
      when 'q', 'quit'
        @die ''
      when 'vsplit', 'hsplit', 'split'
        return @Window.active_tab.split args[0], args[1]
      when 'listen'
        ServerController = require './server'
        new ServerController App: @, port: @config.socket
      when 'connect'
        ClientController = require './client'
        new ClientController App: @, port: @config.socket
