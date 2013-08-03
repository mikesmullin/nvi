// Generated by CoffeeScript 1.6.3
var fs, logger, path;

fs = require('fs');

path = require('path');

module.exports = logger = (function() {
  function logger() {}

  logger.out = function(s) {
    return fs.appendFile(path.join(__dirname, '..', 'logs', 'nvi.log'), s + "\n", function(err) {
      if (err) {
        throw err;
      }
    });
  };

  return logger;

})();
