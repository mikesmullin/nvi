HydraBuffer = require './HydraBuffer'
Cursor = require './Cursor'

module.exports = class View
# belong to a user
# has one hydrabuffer
# renders text from hydrabuffers
# also renders cursors over the top of hydrabuffer text
# redraws its section of real-estate on-screen on-demand
# remember: treeview is also a view, with an option set for curline_bg
  constructor: (o) ->
    @tab = o.tab
    @tab.active_view = @ if o.active
    @x = o.x
    @y = o.y
    @w = o.w
    @h = o.h
    # although there can be many cursors in a single view
    @cursors = [new Cursor user: Window.current_user, view: @, x: 0, y: 0] # cursor 0 is always my_cursor
    # or the one that is controlled by the current_user
    # the rest of the cursors belong to other views/users of the same file
    @buffer = HydraBuffer view: @, file: o.file # will instantiate itself if needed
    # that depends on whether we were given a filename
    # but let HydraBuffer track and decide on this internally
    @lines = @buffer.data.split("\n")
    @lines.pop() # discard last line erroneously appended by fs.read
    @gutter = repeat (Math.max 3, @lines.length.toString().length + 2), ' '
    @draw()
    Window.set_status "\"#{@buffer.alias}\", #{@lines.length}L, #{@buffer.data.length}C"
  resize: ({@w, @h}) ->
    Logger.out "View.resize(#{@w}, #{@h})"
    @draw()
  draw: ->
    Logger.out 'View.draw() was called.'
    yy = Math.min @lines.length, @h
    Logger.out "@lines.length is #{@lines.length}, yy is #{yy}"
    ln = 1
    # TODO: fix last line shown always on bottom; overriding actual line
    if ln < @lines.length
      for ln in [1..yy]
        line = @lines[ln-1]
        Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(@x+1,@y+ln).echo((@gutter+ln).substr((@gutter.length-1) * -1)+' ')
        clipped = line.length > @w
        if clipped
          line = line.substr(0, @w-1) + '>'
        Terminal.xbg(NviConfig.text_bg).xfg(NviConfig.text_fg).echo(line).clear_eol()
      Logger.out "now ln #{ln}, @h #{@h}"
    # TODO: fix tildes not being drawn on resize
    if @lines.length < @h
      for y in [ln..@h]
        Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(@x+1,@y+y).fg('bold').echo('~').fg('unbold')
    Terminal.go(@x+@gutter.length+1,@y+0).xfg(255)
