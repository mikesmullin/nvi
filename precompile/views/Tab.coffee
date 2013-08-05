View = require './View'

# Simple Tabs, and;
# Tiling View Manager
module.exports = class Tab
# has many views
  constructor: (o) ->
    @name = o.name or 'untitled'
    Window.active_tab = @ if o.active
    @resize x: o.x, y: o.y, w: o.w, h: o.h
    @views = [@wrap_layout new View tab: @, file: o.file, x: @x, y: @y, w: @w, h: @ih, active: o.active] # can never have fewer than one view
    return
  resize: (o) ->
    @x = o.x if o.x
    die "Tab.x may not be less than 1!" if @x < 1
    @y = o.y if o.y
    die "Tab.y may not be less than 1!" if @y < 1
    @w = o.w
    die "Tab.w may not be less than 1!" if @w < 1
    # outer
    @h = o.h
    die "Tab.h may not be less than 1!" if @h < 1 # TODO: or 2 if tab bar is present
    # inner
    @ih = o.h # optionally without a tab bar
    @draw()
    if @views
      view.resize w: @w, h: @ih for view in @views
    return
  draw: ->
    # if draw_tab_bar
    return

  @p_to_char: (dim, p) -> @[dim] * p
  wrap_layout: (view) ->
    current_tab = w: @w, h: @ih
    char_to_p = (dim, chars) -> chars / current_tab[dim]
    class Cell # belong to Tabular
      constructor: ({@parent, @width, @content}) ->
        @left = null; @right = null
        @content.layout_parent = @
      resize: (d) -> # vsize
        return if d is 0
        c = @
        if d > 0 # knock right until rightmost
          while c = c.right
            if c.width > char_to_p 'w', 1
              c.width-=d; @.width+=d
              return
          return Logger.out "no more room right!"
        else # knock left until leftmost
          while c = c.left
            if c.width > char_to_p 'w', 1
              c.width-=d; @.width+=d
              return
          return Logger.out "no more room left!"
      remove: ->
        @left = @right; @right = @left
    class Tabular  # as in a type of Table that only has one row
      constructor: ({@Tab, cols, @height}, content) ->
        @top = null; @bottom = null
        @vcols = []
        for x in [0...cols]
          @vcols.push new Tab.Cell parent: @, width: 1 / cols, content: content
      vsplit: (cell_content) ->
        l = 1 / (@vcols.length+1)
        col.width = l for col in @vcols
        c = new Tab.Cell parent: @, width: l, content: cell_content
        c.right = @vcols[0]; c.left = @vcols[0].left if @vcols[0].left; @vcols[0].left = c; @vcols.unshift c; # prepend Cell left
        return c
      hrows: ->
        t = @; hrows = [t] # start from this
        hrows.unshift t while t = t.top if t.top # explore to top
        hrows.push t while t = t.bottom if t.bottom # explore to bottom
        return hrows
      hsplit: (bottom, content) ->
        hrows = @hrows()
        h = 1 / (hrows.length + 1)
        t.height = h for t in hrows
        t = new Tab.Tabular Tab: @Tab, cols: 1, height: h, content
        t.bottom = @; t.top = @top if @top; @top = t # prepend Tabular top
        return t
      resize: (d) -> # hsize
        return if d is 0
        t = @
        if d > 0 # knock down until bottom
          while t = t.bottom
            if t.height > char_to_p 'h', 1
              t.height-=d; @.height+=d
              return
          return Logger.out "no more room bottom!"
        else # knock up until top
          while t = t.top
            if t.height > char_to_p 'h', 1
              t.height-=d; @.height+=d
              return
          return Logger.out "no more room top!"
      remove: ->
        @top = @bottom; @bottom = @top
    @layout = new Tabular cols: 1, height: 1, view
    return view
  split: (direction, file) ->
    view = @active_view
    lev = view.layout_parent.parent # layout for existing view
    lnv = {} # layout for new view; placeholder
    div_w = 1 # size of divider
    # TODO: account for divider
    # calculate coordinate and dimension changes
    lnv = lev["#{if direction is 'v' then 'v' else ''}split"] null # split with placeholder for view
    # emit resize to views in the layout



    # resize existing view to new coords + dims in layout
    view.resize x: lev.
    view.active = false
    # draw new view in remaining space
    nv = new View
      tab: Window.active_tab
      file: file
      x: new_view.x
      y: new_view.y
      w: new_view.w
      h: new_view.h
      active: true
    nev.content = nv
    Window.active_tab.views.push nv
    return
