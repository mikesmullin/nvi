Socket = require '../models/Socket'

module.exports = class ClientController
  @init: (port) ->
    Logger.filename = 'nvi-client.log'
    s = new Socket
    s.socket_open port, ->
      s.send 'handshake', (-> "%yo\u0000" ), ->
        s.expectOnce 'ack', (-> @recv is "%hey" ), ->
          Window.status_bar.set_text 'connected to host.'
