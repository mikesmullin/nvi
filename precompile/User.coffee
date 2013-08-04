module.exports = class User
# has one or more views
  constructor: (o) ->
    @id = o.id # unique string identifier and alias
    @name = o.name # full name
    @email = o.email # email
    @color = o.color # ansi xterm 256-color id
    #@views = []
