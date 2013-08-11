BufferView = require './BufferView'

# Cells provide a tiling window manager effect
# for BufferViews in Tabs
module.exports = class Cell
# belongs to Tab or another Cell
# has one Cell or BufferView
# has zero or one prev Cell
# has zero or one next Cell
  constructor: (o) ->
    # cells have a size represented in relative percentage units
    @p = o.p
    # cells maintain a chain link relationship with their neighbors
    @next = @prev = null
    # a cell may have zero or more children cells
    # but its only meaningful to track the first child
    # because either way you'd have to iterate to find a specific child
    @first_child = null
    # a cell may hold a first_child cell or a view, but not both
    @view = o.view or null
    # cells relate by dividing from an origin cell
    if o.origin
      # prepend or insert link in neighbor chain
      @next = o.origin
      @prev = o.origin.prev if o.origin.prev
      o.origin.prev = @
      @chain = o.origin.chain
    else
      # cells have attributes shared by the chain
      @chain =
        # chains have direction, and it can change
        dir: o.dir or 'v'
        # chains may have zero or one parent cell
        # but its an important convenience since you would never want
        # to iterate siblings to find the common parent of an orphan cell
        parent: o.parent or null
        # chains have rectangular coordinates and dimensions
        # if you specify a parent, rect is inherited from the parent
        # otherwise, you must specify the chain rect
        x: if o.parent then o.parent.x else o.chain.x
        y: if o.parent then o.parent.y else o.chain.y
        w: if o.parent then o.parent.w else o.chain.w
        h: if o.parent then o.parent.h else o.chain.h
    # cells have rectangular coordinates and dimensions, too
    # but you are not allowed to specify them directly
    # as they are calculated during resize operations
    # based on the cell size percentage relative to its chain rect
    @x = @y = @w = @h = null
    @resize chain: x: @chain.x, y: @chain.y, w: @chain.w, h: @chain.h
  resize: (o) ->
    # TODO: ensure we redraw from top-to-bottom, left-to-right
    #       otherwise the views draw over the top of each other?
    # TODO: make space for individual view status bars
    # TODO: make space for divider bars
    if o?.chain
      @chain.x = o.chain.x if o.chain.x
      die "Cell.chain.x may not be less than 1!" if @chain.x < 1
      @chain.y = o.chain.y if o.chain.y
      die "Cell.chain.y may not be less than 1!" if @chain.y < 1
      @chain.w = o.chain.w if o.chain.w
      die "Cell.chain.w may not be less than 1!" if @chain.w < 1
      @chain.h = o.chain.h if o.chain.h
      die "Cell.chain.h may not be less than 1!" if @chain.h < 1
    # recalculate every cell size in the chain
    # because no cell size stands on its own;
    #   all cell sizes are relative to the chain
    #   any cell size changes also affect siblings in the chain
    i = 0; pc = x: @chain.x, y: @chain.y, w: @chain.w, h: @chain.h; @each_neighbor (cell) ->
      switch cell.chain.dir # account for chain direction
        when 'v' # divider is vertical, so cells are horizontal like columns
          cell.x = pc.x + (i * pc.w)
          cell.y = pc.y # same
          cell.w = Math.floor cell.p * cell.chain.w # relative percentage of the total chain
          cell.h = cell.chain.h # same
        when 'h' # divider is horizontal, so cells are vertical like rows
          cell.x = pc.x # same
          cell.y = pc.y + (i * pc.h)
          cell.w = cell.chain.w # same
          cell.h = Math.floor cell.p * cell.chain.h # relative percentage of the total chain
      die "Cell.x may not be less than 1!" if cell.x < 1
      die "Cell.y may not be less than 1!" if cell.y < 1
      die "Cell.w may not be less than 1!" if cell.w < 1
      die "Cell.h may not be less than 1!" if cell.h < 1
      # invoke resize on affected children and/or views
      if affected_content = cell.view or cell.first_child
        affected_content.resize x: cell.x, y: cell.y, w: cell.w, h: cell.h
      # increment and repeat
      i++; pc = cell; return
    return
  draw: ->
    # TODO: draw the divider
    return

  # instantiates a new view with coords and dims
  # relative to its parent cell and row
  new_view: (o) ->
    o.x = @x; o.y = @y; o.w = @w; o.h = @h # override view coords and dims with cell's
    @view = new BufferView o # instantiate
    @view.cell = @ # bind view to cell for bottom-up iteration
    o.tab.views.push @view # bind to tab for top-level iteration
    return @view

  # iterate neighbor cell chain
  each_neighbor: (cb) ->
    cb c = @, 'origin' # begin with this cell
    cb c = c.prev, 'prev' while c.prev # explore to beginning of chain
    c = @ # reset to this cell
    cb c = c.next, 'next' while c.next # explore to end of chain
    return

  # divides a cell into two chained neighbors
  divide: (view) ->
    # count neighbors
    neighbors = []; @each_neighbor (neighbor, dir) ->
      neighbors[if dir is 'prev' then 'unshift' else 'push'] neighbor
      return
    # calculate their new average size supposing an additional neighbor
    p = 1 / (neighbors.length + 1)
    # resize all existing neighbors to be the same new average size;
    # making room for a new neighbor
    neighbor.p = p for neighbor in neighbors
    # instantiate the new neighbor
    new_neighbor = new Cell origin: @, p: p
    # recalculate dimensions of existing cells in chain
    # and invoke resize on any with views
    @resize()
    # instantiate and return the resulting new view
    # bound to its newly divided cell
    return new_neighbor.new_view view

  # create a parent-child relationship between two existing cells
  # not the same as hsplit or divide; inserts an additional cell child
  # with its own direction and completely new cell chain
  impregnate: (dir, view) ->
    die "must have more than one cell in the chain to impregnate" unless @prev or @next
    die "must not already be impregnated to impregnate" if @first_child
    # temporarily detach the view from this cell
    detached_view = @view
    @view = null
    # re-attach the view to a new cell
    # attach that new cell as a child of this cell
    # name this cell as the new cell's parent
    @first_child = new Cell p: 1, dir: dir, parent: @, view: detached_view
    # divide the new cell into a chain of two
    # with the additional cell containing an additional view as given
    return @first_child.divide view

  vsplit: (view) -> @divide view
  hsplit: (view) ->
    return if @prev or @next # more than one cell
      @impregnate 'h', view
    else # only one cell
      @chain.dir = 'h'
      @divide view

  destroy: (o) -> # called bottom-up from BufferView
    # refuse to destroy the last cell; a tab must always have one view
    return false if tab.views.length < 2
    # link neighbors
    @prev.next = @next if @prev
    @next.prev = @prev if @next
    # children should already have destroyed themselves
    # collapse empty parents recursively
    if @chain.parent.prev is null and @chain.parent.next is null
      @chain.parent.destroy()
    # always ensure the tab.top_cell reference is replaced
    # if its cell is destroyed
    @destroyed = true
    # TODO: it may be more convenient to track tab in the chain attributes
    # TODO: collapse these functions if they aren't used anywhere else
    closest_view = ->
      if @view
        return @view
      else if @first_child
        n = @; n = n.first_child while n.first_child
        return n.view
      return
    tab = closest_view().tab
    if tab.topmost_cell.destroyed
      other = @prev or @next
      topmost_cell = ->
        n = other; n = n.chain.parent while n.chain.parent
        return n
      tab.topmost_cell = topmost_cell()
      tab.resize()
    else
      # call resize on any surviving cells of affected chain
      survivor.resize() if survivor = @prev or @next
    return true # ride into the sunset of garbage collection
