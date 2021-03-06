// Generated by CoffeeScript 1.6.3
var ClientController, Socket;

Socket = require('../models/Socket');

module.exports = ClientController = (function() {
  function ClientController() {}

  ClientController.init = function(port) {
    var s;
    Logger.filename = 'nvi-client.log';
    s = new Socket;
    return s.socket_open(port, function() {
      return s.send('handshake', (function() {
        return "%yo\u0000";
      }), function() {
        return s.expectOnce('ack', (function() {
          return this.recv === "%hey";
        }), function() {
          return Window.status_bar.set_text('connected to host.');
        });
      });
    });
  };

  return ClientController;

})();
