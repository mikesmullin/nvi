// Generated by CoffeeScript 1.6.3
var ServerController, Socket, fs;

Socket = require('../models/Socket');

fs = require('fs');

module.exports = ServerController = (function() {
  function ServerController() {}

  ServerController.init = function(port) {
    return fs.unlink(port, function() {
      var s;
      Logger.filename = 'nvi-server.log';
      s = new Socket;
      s.expectOnce('handshake', (function() {
        return this.recv === "%yo";
      }), function() {
        Window.status_bar.set_text('client connected.');
        return s.send('ack', (function() {
          return "%hey\u0000";
        }), function() {});
      });
      return s.listen(port);
    });
  };

  return ServerController;

})();
