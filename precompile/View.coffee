HydraBuffer = require './HydraBuffer'
Cursor = require './Cursor'

module.exports = class View
# belong to a user
# has one hydrabuffer
# renders both text and cursors from hydrabuffers
# redraws its section of real-estate on-screen
# the treeview is a view, too with an option set for curline_bg
  constructor: (o) ->
    @tab = o.tab
    @hydrabuffer = HydraBuffer
    #@user = User
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
