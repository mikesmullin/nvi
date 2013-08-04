module.exports = class HydraBuffer
# belong to one or more views
# one per buffer
# has one or more cursors
  constructor: ->
    @view = View # by reference
    @buffer = Buffer
    @cursors = [] # array of Cursors
  @from_file: (filename) ->
    fs.open filename, 'r', (err, fd) ->
      buffer = new Buffer 100
      fs.read fd, buffer, 0, buffer.length, 0, (err, bytesRead, buffer) ->
        b.toString 'utf8'
