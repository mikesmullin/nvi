fs = require 'fs'
path =  require 'path'

# its a HydraStream;
# because it gets read by multiple sometimes overlapping views
# allowing them to share a single file
# with the most minimal rewind/seeking/buffering

# its what keeps an in-memory snapshot of all open
# aggregate views for a given Stream
# and allows us to asynchronously update the memory snapshot
# occasionally saving off the composite data to disk
# when it makes sense to do so
# (e.g. host presses Ctrl+S? or client presses it, and host approves)

module.exports = class HydraStream
# belongs to one or more views
# one per stream
  @streams: {} # registry ensures only one instance per stream
  constructor: (o) ->
    # decide whether or not this is a unique request
    # and instantiate only when needed
    if o.file # we're expected to open a file on disk
      # absolute filename path on disk becomes stream unique identifier
      # TODO: maybe fs.realpath() is useful here to resolve past symlinks?
      absfile = path.resolve o.file
      stream_id = 'file://'+absfile
      if HydraStream.streams[stream_id] is undefined
        stream = HydraStream.from_file absfile
    # TODO: support opening other types of streams like stdin, in-memory streams, etc.
    stream.views ||= []
    stream.views.push View
    HydraStream.streams[stream_id] = stream

  @from_file: (absfile) ->
    # TOOD: how to catch errors with *Sync()?
    fs.openSync absfile, 'r'
    # TODO: make stream size equal max view area in bytes
    stream = new Buffer 1024
    # TODO: make stream size flexible so that max can resize mid-chunking
    #       or make my own intermediary stream object to do the same
    fs.readSync fd, stream, 0, stream.length, 0
    b.toString 'utf8'

  # TODO: need ability to seek, rewind, etc.
  #       in a way that works with each stream type
  #       but beginning with file stream only is fine for now
  # TODO: need ability to dynamically resize hydrastream
