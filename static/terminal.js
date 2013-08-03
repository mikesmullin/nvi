// Generated by CoffeeScript 1.6.3
var terminal;

module.exports = terminal = (function() {
  function terminal() {}

  terminal.echo = function(s) {
    var w_delta;
    w_delta = s.length;
    if (w_delta) {
      s.replace(/[\r\n]+/, function() {
        terminal.cursor.y++;
        return '';
      });
      terminal.cursor.x += w_delta;
      if (terminal.cursor.x > terminal.screen.w) {
        terminal.cursor.y += Math.floor(terminal.cursor.x / terminal.screen.w);
        terminal.cursor.x = terminal.cursor.x % terminal.screen.w;
      }
    }
    process.stdout.write(s);
    return this;
  };

  terminal.esc = (function() {
    function _Class(s) {
      process.stdout.write("\x1b" + s);
    }

    _Class.CLEAR_SCREEN = '[2J';

    _Class.CLEAR_EOL = '[K';

    _Class.CLEAR_EOF = '[J';

    _Class.POS = function(x, y) {
      return "[" + y + ";" + x + "H";
    };

    _Class.color = (function() {
      function _Class() {}

      _Class.reset = '[0m';

      _Class.bold = '[1m';

      _Class.inverse = '[7m';

      _Class.strike = '[9m';

      _Class.unbold = '[22m';

      _Class.black = '[30m';

      _Class.red = '[31m';

      _Class.green = '[32m';

      _Class.yellow = '[33m';

      _Class.blue = '[34m';

      _Class.magenta = '[35m';

      _Class.cyan = '[36m';

      _Class.white = '[37m';

      _Class.xterm = function(i) {
        return "[38;5;" + i + "m";
      };

      _Class.bg_reset = '[49m';

      _Class.bg_black = '[40m';

      _Class.bg_red = '[41m';

      _Class.bg_green = '[42m';

      _Class.bg_yellow = '[43m';

      _Class.bg_blue = '[44m';

      _Class.bg_magenta = '[45m';

      _Class.bg_cyan = '[46m';

      _Class.bg_white = '[47m';

      _Class.bg_xterm = function(i) {
        return "[48;5;" + i + "m";
      };

      return _Class;

    })();

    return _Class;

  }).call(this);

  terminal.clear = function() {
    terminal.esc(terminal.esc.CLEAR_SCREEN);
    return this;
  };

  terminal.cursor = {
    x: null,
    y: null
  };

  terminal.screen = {
    w: null,
    h: null
  };

  terminal.buffer = {
    w: null,
    h: 2
  };

  terminal.go = function(x, y) {
    terminal.cursor.x = x;
    terminal.cursor.y = y;
    terminal.esc(terminal.esc.POS(x, y));
    logger.out("cursor now " + x + ", " + y);
    return this;
  };

  terminal.move = function(x, y) {
    var dx, dy;
    if (y == null) {
      y = 0;
    }
    dx = terminal.cursor.x + x;
    dy = terminal.cursor.y + y;
    if (dx > 4 && dx < terminal.screen.w && dy > 0 && dy <= terminal.buffer.h) {
      return this.go(dx, dy);
    }
  };

  terminal.fg = function(color) {
    terminal.esc(terminal.esc.color[color]);
    return this;
  };

  terminal.bg = function(color) {
    terminal.esc(terminal.esc.color['bg_' + color]);
    return this;
  };

  terminal.xfg = function(i) {
    terminal.esc(terminal.esc.color.xterm(i));
    return this;
  };

  terminal.xbg = function(i) {
    terminal.esc(terminal.esc.color.bg_xterm(i));
    return this;
  };

  terminal.clear_screen = function() {
    var y, _i, _ref;
    terminal.go(1, 1).clear();
    for (y = _i = 0, _ref = terminal.screen.h; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
      terminal.clear_eol();
    }
    terminal.go(1, 1);
    return this;
  };

  terminal.clear_eol = function() {
    terminal.echo(repeat(terminal.screen.w - terminal.cursor.x, ' '));
    return this;
  };

  return terminal;

}).call(this);
