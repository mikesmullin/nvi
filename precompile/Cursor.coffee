module.exports = class Cursor
# belong to a user
# belong to a hydrabuffer
# cursors can also highlight and block edit
  constructor: (o) ->
    @user = o.user
    @view = o.view
    @x = null
    @y = null
    @w = 1
    @h = 1
