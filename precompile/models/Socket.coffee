net = require 'net'

module.exports = class Socket
  constructor: ->
    @events = {}
    @socket = null
    @connected = false
    @buffer = ''
    #NviConfig.socket
    @state = {}
    @expectations = Once: [], Anytime: []
    @on 'data', @receive

  # EventEmitter clone
  # with improvements
  on: (event, cb) ->
    @events[event] ||= []
    @events[event].push cb
  once: (event, cb) ->
    wrapped = null
    @on event, wrapped = =>
      for f, i in @events[event] when f is wrapped
        @events[event].splice i, 1
        break
      cb.apply null, arguments
  removeAllListeners: (event) ->
    delete @events[event]
  emit: (event, args...) ->
    if @events[event]? and @events[event].length
      cb.apply null, args for k, cb of @events[event]
  emitOne: (event, args...) ->
    if @events[event]? and @events[event].length
      @events[event][0].apply null, args
  emitLast: (event, args...) ->
    if @events[event]? and @events[event].length
      cb = @events[event][@events[event].length-1]
      @events[event] = [] # flush events before and including last
      cb.apply null, args
  emitOneIfAnyThen: (event, next) ->
    if @events[event]? and @events[event].length # if any event is queued
      @events[event][0].call null, next # call event, and event will call next
    else # otherwise
      next() # just call next

  # basic socket operations
  listen: (port, cb) ->
    # TODO: make this able to listen on the same port across threads
    server = net.createServer allowHalfOpen: false, (@socket) =>
      @connected = true
      Logger.out remote: "#{@socket.remoteAddress}:#{@socket.remotePort}", 'client connected'
      @socket.on 'data', (d) =>
        @socket_receive.apply @, arguments
      cb @socket if typeof cb is 'function'
      @emit 'connection'
    #server.setNoDelay false # disable Nagle algorithm; forcing an aggressive socket performance improvement
    server.on 'end', =>
      @connected = false
      Logger.out type: 'fail', 'remote host sent FIN'
    server.on 'close', =>
      @connected = false
      Logger.out type: 'fail', 'socket closed'
      @emit 'close'
    server.on 'error', (err) =>
      Logger.out type: 'fail', "Socket error: "+ JSON.stringify err
    server.on 'timeout', =>
    server.listen port, =>
      Logger.out "listening on #{port}"
      @emit 'listening'

  socket_open: (port, cb) ->
    @host = '' #host if host
    @port = port if port
    Logger.out remote: "#{@host}:#{@port}", 'opening socket'
    @socket = new net.Socket allowHalfOpen: false
    @socket.setTimeout 10*1000 # wait 10sec before retrying connection
    @socket.setNoDelay false # disable Nagle algorithm; forcing an aggressive socket performance improvement
    @connected = false
    @socket.on 'data', (d) =>
      @socket_receive.apply @, arguments
    @socket.on 'end', =>
      @connected = false
      Logger.out type: 'fail', 'remote host sent FIN'
    @socket.on 'close', =>
      @connected = false
      Logger.out type: 'fail', 'socket closed'
      @emit 'close'
    @socket.on 'error', (err) =>
      Logger.out type: 'fail', "Socket error: "+ JSON.stringify err
    @socket.on 'timeout', =>
      # this seems to get fired randomly; perhaps when packet send is delayed; unreliable
    @emit 'connecting'
    @socket.connect @port, =>
      @connected = false
      Logger.out 'socket open'
      cb @socket if typeof cb is 'function'
      @emit 'connection'

  close: (err) ->
    @connected = false
    # TODO: make this hangup on the current client
    # but not drop other existing clients
    # and keep listening for new clients
    Logger.out type: 'fail', "[ERR] #{err}" if (err)
    Logger.out 'sent FIN to remote host'
    @socket.end()
    Logger.out 'destroying socket to ensure no more i/o happens'
    @socket.destroy()

  socket_send: (s, cb) ->
    Logger.out type: 'send', JSON.stringify s, null, 2
    @socket.write s, 'utf8', =>
      cb()

  socket_receive: (buf) ->
    # remote can transmit messages split across several packets,
    # as well as more than one message per packet
    packet = buf.toString()
    Logger.out type: 'recv', JSON.stringify packet, null, 2
    @buffer += packet
    while (pos = @buffer.indexOf("\u0000")) isnt -1 # we have a complete message
      recv = @buffer.substr 0, pos
      @buffer = @buffer.substr pos+1
      switch recv[0]
        when '%' # Delimiter
          [cmd, data...] = recv.substr(1,recv.length-1).split('%')
          @emit 'data', 'd', cmd, data, recv
        when '{' # JSON
          data = JSON.parse recv
          @emit 'data', 'json', data.b?._cmd, data, recv
    return

  # convenient helpers
  send: (description, data_callback, cb) ->
    Logger.out "send: #{description}"
    @socket_send data_callback.apply(state: @state), cb

  hangup: (reason, cb) ->
    Logger.out type: 'fail', "Server hungup on client. #{reason}"
    @on 'close', cb
    @close()

  # expectation system
  _pushExpectation: ->
    e = {}
    switch arguments.length
      when 4 then [type, e.description, e.test_callback, e.callback] = arguments
      when 5 then [type, e.description, e.test_callback, e.within, e.callback] = arguments
    @expectations[type] ||= []
    @expectations[type].push e
    return
  expectOnce: (description, test_callback, cb) -> @_pushExpectation.call @, 'Once', description, test_callback, cb
  expectOnceWithin: (description, test_callback, within, cb) -> @_pushExpectation.call @, 'Once', description, test_callback, within, cb
  expectAnytime: (description, test_callback, cb) -> @_pushExpectation.call @, 'Anytime', description, test_callback, cb
  _clearExpectation: (etype, i) ->
    @expectations[etype].splice i, 1

  receive: (type, cmd, data, recv) =>
    for nil, etype of ['Once', 'Anytime']
      for expectation, i in @expectations[etype]
        if expectation.test_callback.apply { state: @state, type: type, cmd: cmd, data: data, recv: recv }
          Logger.out "received #{type}: #{expectation.description}"
          Logger.out type: 'data', JSON.stringify { type: type, cmd: cmd, data: data }
          @_clearExpectation etype, i if etype is 'Once'
          if typeof expectation.callback is 'function'
            expectation.callback.apply { state: @state, data: data, recv: recv }
          return true
    Logger.out type: 'fail', 'received: unexpected response'
    Logger.out type: 'fail', JSON.stringify { type: type, cmd: cmd, data: data }
    Logger.out "expectOnce queue: "+ JSON.stringify @expectations.Once
    Logger.out "expectAnytime queue: "+ JSON.stringify @expectations.Anytime
