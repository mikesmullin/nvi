HydraBuffer = require '../models/HydraBuffer'
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
    @gutter = repeat (Math.max 4, @lines.length.toString().length + 2), ' '
    @resize x: o.x, y: o.y, w: o.w, h: o.h

    #Window.set_status "\"#{@buffer.base}\", #{@lines.length}L, #{@buffer.data.length}C"
    @set_status Terminal
      .xbg(NviConfig.view_status_bar_active_l1_bg).xfg(NviConfig.view_status_bar_active_l1_fg)
      .echo(@buffer.path).fg('bold')
      .xfg(NviConfig.view_status_bar_active_l1_fg_bold).echo(@buffer.base+' ')
      .fg('unbold')
      .xbg(NviConfig.view_status_bar_active_bg).xfg(NviConfig.view_status_bar_active_fg)
      .get_clean()

    # a view has one or more cursors
    # but only one is possessed at a given time
    # cursor 0 is always the current_user's cursor
    # only cursor 0 can become possessed by the current_user
    @cursors = [new ViewCursor user: Window.current_user, view: @, x: @x, y: @y, possessed: true]
    return
  resize: (o) ->
    Logger.out "View.resize(#{JSON.stringify o})"
    @x = o.x if o.x
    die "View.x may not be less than 1!" if @x < 1
    @y = o.y if o.y
    die "View.y may not be less than 1!" if @y < 1
    @w = o.w
    die "View.w may not be less than 1!" if @w < 1
    # outer height
    @h = o.h; die "View.h may not be less than 2!" if @h < 2
    # inner height (after decorators like status bar)
    @iw = o.w
    @ih = o.h - 1 # make room for status bar
    @draw()
    return
  draw_status_bar: ->
    Terminal.clear_space
      x: @x, y: @y + @ih, w: @w, h: 1,
      bg: NviConfig.view_status_bar_active_bg,
      fg: NviConfig.view_status_bar_active_fg
    return
  draw: ->
    Logger.out 'View.draw() was called.'
    # count visible lines; truncate to view inner height when necessary
    visible_line_h = Math.min @lines.length, @ih
    # draw visible lines
    # TODO: fix last line shown always on bottom; overriding actual line
    for ln in [0...visible_line_h]
      line = @lines[ln]
      # if necessary, truncate line to visible width and append a truncation symbol (>)
      if line.length > @iw then line = line.substr(0, @iw-1)+'>'
      # draw line gutter
      # TODO: we shouldn't have to keep setting go(). we clear to eol so it should line up perfectly on next line
      #       just set go once outside of for() and then fix the Terminal.echo() math
      Terminal.xbg(NviConfig.view_gutter_bg).xfg(NviConfig.view_gutter_fg).go(@x,@y+ln).echo((@gutter+(ln+1)).substr(-1*(@gutter.length-1))+' ')
      # echo line, erasing any remaining line space to end of visible width
      Terminal.xbg(NviConfig.view_text_bg).xfg(NviConfig.view_text_fg).echo(line).clear_n(@iw - @gutter.length - line.length).flush()
    # draw tilde placeholder lines, erasing any remaining line space to end of visible height
    if visible_line_h < @ih
      for y in [visible_line_h...@ih]
        Terminal.xbg(NviConfig.view_gutter_bg).xfg(NviConfig.view_gutter_fg).go(@x,@y+y).fg('bold').echo('~').fg('unbold').clear_n(@iw-1).flush()
    @draw_status_bar()
    if @cursors
      cursor.draw() for cursor in @cursors
    return
  set_status: (s) ->
    @draw_status_bar()
    #TODO: find out why this doesn't clear to eol
    Terminal.echo(s.substr(0, View.w)).clear_eol().flush()
    # TODO: this may not always be the right thing to do
    if @cursors
      @cursors[0].draw() # return cursor to user
    return
