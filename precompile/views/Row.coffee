module.exports = class Row
# belongs to Tab
# has zero or one up Row
# has zero or one down Row
  constructor: ({@tab, @x, @y, @w, @h, @ph}) ->
    # ph = percentage height
    @up = @down = null
    @cells = []
    @tab.rows.push @ # register with tab for top-down iteration
  destroy: -> # call top-down from Tab if possible
    @up = @down; @down = @up # introduce neighbors and depart
    for cell in @cells
      cell.view.destroy()
      cell.left = cell.right = null
    @cells = []
    for row, i in @tab.rows when row is @
      @tab.rows.splice i, 1 # delete
      return
  resize: ->
    @x = @tab.x
    #n = @
    #while n = n.left
    #  @x += neighbor.w


    @y = @tab.y

    @x = @x
    @y = @y
    # TODO: calc w by summing cells w
    @w = 0
    for cell in @cells
      @w = 
    @w = @w
    @h = @ih * @row.ph # % to chars

  #@p_to_char: (dim, p) -> @[dim] * p
  #@char_to_p: (dim, chars) -> chars / current_tab[dim]
  #hresize: (d) -> # hsize
  #  return if d is 0
  #  t = @
  #  if d > 0 # knock down until bottom
  #    while t = t.bottom
  #      if t.height > char_to_p 'h', 1
  #        t.height-=d; @.height+=d
  #        return
  #    return Logger.out "no more room bottom!"
  #  else # knock up until top
  #    while t = t.top
  #      if t.height > char_to_p 'h', 1
  #        t.height-=d; @.height+=d
  #        return
  #    return Logger.out "no more room top!"

  # TODO: parent is @row or @tab
  # TODO: width is @pw, height is @ph
  # TODO: content is now view
  #vresize: (d) -> # vsize
  #  return if d is 0
  #  c = @
  #  if d > 0 # knock right until rightmost
  #    while c = c.right
  #      if c.width > char_to_p 'w', 1
  #        c.width-=d; @.width+=d
  #        return
  #    return Logger.out "no more room right!"
  #  else # knock left until leftmost
  #    while c = c.left
  #      if c.width > char_to_p 'w', 1
  #        c.width-=d; @.width+=d
  #        return
  #    return Logger.out "no more room left!"
