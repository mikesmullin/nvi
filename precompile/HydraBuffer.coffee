fs = require 'fs'
path =  require 'path'

# its a HydraBuffer;
# because it gets read by multiple sometimes overlapping views
# allowing them to share a single file
# with the most minimal rewind/seeking/buffering

# its what keeps an in-memory snapshot of all open
# aggregate views for a given Buffer
# and allows us to asynchronously update the memory snapshot
# occasionally saving off the composite data to disk
# when it makes sense to do so
# (e.g. host presses Ctrl+S? or client presses it, and host approves)

module.exports = class HydraBuffer
# belongs to one or more views
# one per stream
  @buffers: {} # registry ensures only one instance per stream
  constructor: (o) ->
    if o.file isnt undefined # we're expected to open a file on disk
      # absolute filename path on disk becomes buffer unique identifier
      # TODO: maybe fs.realpath() is useful here to resolve past symlinks?
      buffer =
        type: 'file'
        id: path.resolve o.file
        alias: path.basename o.file
    else
      buffer = type: 'memory', id: null, alias: 'untitled'

    # decide whether or not this is a unique request
    if buffer.id is null or HydraBuffer.buffers[buffer.id] is undefined
      # instantiate new buffer only when needed
      buffer.views = []
      HydraBuffer.buffers[buffer.id] = buffer

    buffer = HydraBuffer.buffers[buffer.id]
    buffer.views.push o.view # remember which views are using this buffer

    switch buffer.type
      when 'file'
        buffer.data = fs.readFileSync buffer.id, encoding: 'utf8'
      when 'memory'
        buffer.data = ''

    return buffer
