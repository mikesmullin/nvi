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
    # although there can be many cursors in a single view
    @cursors = [new Cursor] # cursor 0 is always my_cursor
    # or the one that is controlled by the current_user
    # the rest of the cursors belong to other views/users of the same file
    @hydrabuffer = HydraBuffer view: @, file: o.file # will instantiate itself if needed
    # that depends on whether we were given a filename
    # but let HydraBuffer track and decide on this internally
    @w = null
    @h = null
    @offset = null
  resize: ->
    @draw()
  draw: ->
    Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(1,1).echo('  1 ')
    Terminal.xbg(NviConfig.text_bg).xfg(NviConfig.text_fg).echo("how is this?").clear_eol()
    Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).echo('  2 ')
    Terminal.xbg(NviConfig.text_bg).xfg(NviConfig.text_fg).echo("hehe").clear_eol()
    for y in [Terminal.cursor.y..Terminal.screen.h]
      Terminal.xbg(NviConfig.gutter_bg).xfg(NviConfig.gutter_fg).go(1,y).fg('bold').echo('~').fg('unbold')
    Terminal.go(8,2).xfg(255)
