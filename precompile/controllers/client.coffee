Socket = require '../models/Socket'

module.exports = class ClientController
  constructor: (o) ->
    @App = o.App
    @s = new Socket
    @App.Logger.filename = 'nvi-client.log'
    @s.socket_open o.port, ->
      @s.send 'handshake', (-> "%yo\u0000" ), ->
        @s.expectOnce 'ack', (-> @recv is "%hey" ), ->
          @App.Window.status_bar.set_text 'connected to host.'
