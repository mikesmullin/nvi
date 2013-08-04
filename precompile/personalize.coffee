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
  constructor: ->
    @id = '' # unique string identifier and alias
    @name = '' # full name
    @email = '' # email
    @color = null # ansi xterm 256-color id
    @views = []

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

class View
# belong to a user
# has one hydrabuffer
# renders both text and cursors from hydrabuffers
  constructor: ->
    @hydrabuffer = HydraBuffer
    @user = User
    @w = null
    @h = null
    @offset = null




module.exports = (nvi) ->
  logger.out 'will personalize'

  process.stdin.on 'keypress', (ch, key) =>
    switch key.name
      when 'left'
        @terminal.move -1
      when 'right'
        @terminal.move 1
      when 'up'
        @terminal.move 0, -1
      when 'down'
        @terminal.move 0, 1


