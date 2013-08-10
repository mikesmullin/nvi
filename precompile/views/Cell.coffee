BufferView = require './BufferView'
Row = require './Row'

# Cells and Rows provide a bottom-up hierarchy
# for tiling window management
module.exports = class Cell
# belongs to Row
# has one BufferView
# has zero or one left Cell
# has zero or one right Cell
  constructor: ({@row, @pw}) ->
    # pw = percentage width
    @x = @y = @w = @h = 0
    @left = @right = null
    @row.cells.push @ # register with row for top-down iteration
  # translate relative cell rectangle coordinates and dimensions
  # to absolute character unit values, relative to cell and row
  resize: ->
    # TODO: figure out indexOf() in the @rows.cells array
    #       in the most efficient way possible
    # TODO; fix x, y calc

    @x = @row.x
    @y = @row.y
    @w = @w * @pw # % to chars
    @h = @ih * @row.ph # % to chars
    @view.resize() if @view
  # instantiates a new view with coords and dims
  # relative to its parent cell and row
  new_view: (o) ->
    @resize() # recalc latest cell absolutes
    {o.x, o.y, o.w, o.h} = @ # override view coords and dims with cell's
    view = new BufferView o # instantiate
    view.cell = @ # bind view to cell for bottom-up iteration
    @row.tab.views.push view # bind to tab for top-level iteration
    return view
  # a single neighbors array will contain all rows, or all cells
  # depending on the direction 'up' or 'left'
  each_neighbor: (prev, next, cb) ->
    origin_neighbor = if prev is 'up' then @row else @
    cb n = origin_neighbor, null # begin with this cell or row
    cb n, prev while n = n[prev] # explore to beginning of chain
    cb n, next, while n = n[next] # explore to end of chain
    return origin_neighbor
  # divides a cell into two--vertically or horizontally
  divide: (prev, next, dim, view) ->
    # TODO: one behavior that is interesting in vim
    #       is that the root-level rows wont insert new rows
    #       instead they wrap themselves in a row and then divide
    #       i'm not sure how i feel about that;
    #       it may be extra complexity
    #       or i may learn that its actually an optimization
    #       when it comes to resizing rows and redrawing only the
    #       views you need to.
    # count vertically or horizontally
    # all like neighbors in a straight line
    neighbors = []
    origin_neighbor = @each_neighbor prev, next, (neighbor, dir) ->
      neighbors[if dir is prev then 'unshift' else 'push'] neighbor
    # calculate their new average size supposing an additional neighbor
    p = 1 / (neighbors.length + 1)
    # resize all existing neighbors to be the same new average size;
    # making room for a new neighbor
    neighbor[dim] = p for neighbor in neighbors
    # instantiate the new neighbor
    if prev is 'up' # rows
      row = new Row ph: p
      cell = new Cell row: row, pw: 1
      new_neighbor = row
      row = null # unset
    else # cells
      new_neighbor = cell = new Cell row: @row, pw: p
    # insert link in chain;
    # prepending this new neighbor before the origin neighbor
    new_neighbor[prev] = origin_neighbor
    new_neighbor[next] = origin_neighbor[next] if origin_neighbor[next]
    origin_neighbor[next] = new_neighbor
    # recalculate existing affected cell dimensions
    # and emit resize to their views
    new_neighbor.each_neighbor prev, next, (neighbor, dir) ->
      neighbor.resize()
    # instantiate and return the resulting new view
    # bound to its newly divided cell
    return view = cell.new_view view
  hsplit: (view) -> @divide @, 'up', 'down', 'ph', view
  vsplit: (view) -> @divide @, 'left', 'right', 'pw', view
  destroy: (o) -> # call top-down from Row if possible
    @left = @right; @right = @left # introduce neighbors and depart
    @view.destroy()
    for cell, i in @row.cells when cell is @
      @row.cells.splice i, 1 # delete
      return
