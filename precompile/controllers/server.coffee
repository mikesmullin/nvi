Socket = require '../models/Socket'
fs = require 'fs'

module.exports = class ServerController
  @init: (port) ->
    fs.unlink port, -> # delete the file socket if it exists
      Logger.filename = 'nvi-server.log'
      s = new Socket
      s.expectOnce 'handshake', (-> @recv is "%yo" ), ->
        Window.status_bar.set_text 'client connected.'
        s.send 'ack', (-> "%hey\u0000" ), ->
      s.listen port
