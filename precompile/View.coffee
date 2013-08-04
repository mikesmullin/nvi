HydraBuffer = require './HydraBuffer'
ViewCursor = require './ViewCursor'

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
    @buffer = HydraBuffer view: @, file: o.file # will instantiate itself if needed
    # that depends on whether we were given a filename
    # but let HydraBuffer track and decide on this internally
    @lines = @buffer.data.split("\n")
    @lines.pop() # discard last line erroneously appended by fs.read
    @lines = [''] unless @lines.length >= 1 # may never have less than one line
    @gutter = repeat (Math.max 3, @lines.length.toString().length + 2), ' '
    @resize x: o.x, y: o.y, w: o.w, h: o.h
    # although there can be many cursors in a single view
    # @cursors[0] is always the current_user's cursor
    # the remaining cursors belong to other views/users of the same file
    @cursors = [new ViewCursor user: Window.current_user, view: @, x: @x, y: @y]
    Window.set_status "\"#{@buffer.alias}\", #{@lines.length}L, #{@buffer.data.length}C"
  resize: (o) ->
    Logger.out "View.resize(#{JSON.stringify o})"
    @x = o.x
    die "View.x may not be less than 1!" if @x < 1
    @y = o.y
    die "View.y may not be less than 1!" if @y < 1
    @w = o.w
    die "View.w may not be less than 1!" if @w < 1
    # outer height
    @h = o.h; die "View.h may not be less than 2!" if @h < 2
    # inner height (after decorators like status bar)
    @iw = o.w
    @ih = o.h - 1
    @draw()
  draw_status_bar: ->
    x = @x; y = @y + @h; w = @w; h = 1
    Terminal.clear_space x: x, y: y, w: w, h: h, fg: 255, bg: 196
    Terminal.echo "View.status_bar here"
  draw: ->
    Logger.out 'View.draw() was called.'
    # count visible lines; truncate to view inner height when necessary
    visible_line_h = Math.min @lines.length, @ih
    # draw visible lines
    # TODO: fix last line shown always on bottom; overriding actual line
    for ln in [0..visible_line_h]
      line = @lines[ln]
      # if necessary, truncate line to visible width and append a truncation symbol (>)
      if line.length > @iw then line = line.substr(0, @iw-1)+'>'
      # draw line gutter
      Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(@x,@y+ln).echo((@gutter+(ln+1)).substr((@gutter.length-1) * -1)+' ')
      # echo line, erasing any remaining line space to end of visible width
      Terminal.xbg(NviConfig.text_bg).xfg(NviConfig.text_fg).echo(line).clear_n(@iw - line.length)
    # draw tilde placeholder lines, erasing any remaining line space to end of visible height
    # TODO: fix tildes not being redrawn on resize
    if visible_line_h < @ih
      for y in [visible_line_h..@ih]
        Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(@x,@y+y).fg('bold').echo('~').fg('unbold').clear_n(@iw-1)

    @draw_status_bar()
    @cursors[0].return_to_user()
