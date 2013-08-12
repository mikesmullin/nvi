Socket = require '../models/Socket'
fs = require 'fs'

module.exports = class ServerController
  constructor: (o) ->
    @App = o.App
    @s = new Socket
    fs.unlink o.port, -> # delete the file socket if it exists
      @App.Logger.filename = 'nvi-server.log'
      @s.expectOnce 'handshake', (-> @recv is "%yo" ), ->
        @App.Window.status_bar.set_text 'client connected.'
        @s.send 'ack', (-> "%hey\u0000" ), ->
      @s.listen port
