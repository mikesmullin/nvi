View = require './View'

module.exports = class Tab
# has many views
  constructor: (o) ->
    @name = o?.name or 'untitled'
    @views = [new View tab: @] # can never have fewer than one view
  resize: ->
    view.resize() for view in @views
    @draw()
  draw: ->
    # if draw_tab_bar
    view.draw() for view in @views
