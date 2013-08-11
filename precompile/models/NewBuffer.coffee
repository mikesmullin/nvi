module.exports =
  HydraBuffer: class HydraBuffer
    constructor: (@o, @text)->
      @buf = ''
      @symbols = {}
      @x = @y = @i = @l = null
      @lines = []
      @parse @text
    # get raw bytes from of buffer
    # hopefully they are all ascii 32-126
    toString: -> @text
    # register symbols and their byte offsets
    # in a two-dimensional grid for quick lookup
    # during rendering
    add_symbol: (x, y, sym, b) ->
      @symbols[x] ||= {}
      @symbols[x][y] = sym: sym, byte: b
      @append_buf sym
    # append a character to the parser buffer
    append_buf: (s) ->
      @buf += s
      @x++
    # flush the parser buffer to a line
    # in the buffer grid to begin to emulate
    # an editor window
    flush_buf: ->
      @lines.push @buf
      @buf = ''
      @x = 1
      @y++
    # parse bytes into lines
    # and characters clipped as if within
    # a constrained BufferView
    parse: (@text) ->
      @lines = []
      @l = @text.length
      @i = -1
      @x = 1; @y = 1
      while ++@i < @l
        switch @text[@i]
          when "\n"
            @flush_buf()
          when "\r"
            @add_symbol @x, @y, @o.whitespace.cr, @i+1
          when "\t"
            @add_symbol @x, @y, @o.whitespace.tab, @i+1
          else
            @append_buf @text[@i]
      @flush_buf()
      return @lines

  BufferView: class BufferView
    constructor: (@buffer) ->
    resize: ->
    draw: ->
      # TODO: add support for rendering binary data using hexdump format
      # TODO: this is the layer where colors are added
      # every character rendered will have to be checked against the
      # symbol table to realize coloring
      @buffer.lines.join "\n"

  BufferViewCursor: class BufferViewCursor
    constructor: ({@buffer, @x, @y, @w, @h}) ->
    resize: (o) ->
      @w = o.w if o.w
      @h = o.h if o.h
    go: (@x, @y) ->
    move: (dx, dy) ->
      @x += dx
      @y += dy
    getSelection: ->
      # TODO: convert string to matrix
      # well its like a matrix but it doesn't create all the whitespace
      # when you have disproportionately long lines
      @buffer.toString().substr @x-1, @w
