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
# belong to one or more views
# one per buffer
  constructor: (o) ->
    @view = View # by reference
    @file = o.file
    # decide whether or not this is a unique request
    # and instantiate only when needed
    # TODO: we need to make a session list in HydraBuffer for streams
    # so we can recognize the same stream and fork it
    @buffer = new Buffer
  @from_file: (filename) ->
    fs.open filename, 'r', (err, fd) ->
      buffer = new Buffer 100
      fs.read fd, buffer, 0, buffer.length, 0, (err, bytesRead, buffer) ->
        b.toString 'utf8'
