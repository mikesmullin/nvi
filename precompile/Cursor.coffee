module.exports = class Cursor
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
