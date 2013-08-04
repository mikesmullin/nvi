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
# one per buffer
  @buffers: {} # registry ensures only one instance per buffer
  constructor: (o) ->
    # decide whether or not this is a unique request
    # and instantiate only when needed
    if o.file # we're expected to open a file on disk
      # absolute filename path on disk becomes buffer unique identifier
      # TODO: maybe fs.realpath() is useful here to resolve past symlinks?
      absfile = path.resolve o.file
      buffer_id = 'file://'+absfile
      if HydraBuffer.buffers[buffer_id] is undefined
        buffer = HydraBuffer.from_file absfile
    # TODO: support opening other types of buffers like stdin, in-memory buffers, etc.
    buffer.views ||= []
    buffer.views.push View
    HydraBuffer.buffers[buffer_id] = buffer

  @from_file: (absfile) ->
    # TOOD: how to catch errors with *Sync()?
    fs.openSync absfile, 'r'
    # TODO: make buffer size equal max view area in bytes
    buffer = new Buffer 1024
    # TODO: make buffer size flexible so that max can resize mid-chunking
    #       or make my own intermediary buffer object to do the same
    fs.readSync fd, buffer, 0, buffer.length, 0
    b.toString 'utf8'

  # TODO: need ability to seek, rewind, etc.
  #       in a way that works with each buffer type
  #       but beginning with file buffer only is fine for now
  # TODO: need ability to dynamically resize hydrabuffer
