// Generated by CoffeeScript 1.6.3
var Terminal;

module.exports = Terminal = (function() {
  function Terminal() {}

  Terminal.write = function(s) {
    process.stdout.write(s);
    return this;
  };

  Terminal.buffer = '';

  Terminal.push_raw = function(s) {
    Terminal.buffer += s;
    return this;
  };

  Terminal.echo = function(s) {
    if (s.length) {
      Terminal.cursor.x += s.length;
      if (Terminal.cursor.x > Terminal.screen.w) {
        Terminal.cursor.y += Math.floor(Terminal.cursor.x / Terminal.screen.w);
        Terminal.cursor.x = Terminal.cursor.x % Terminal.screen.w;
      }
      s.replace(/\n/g, function() {
        return Terminal.cursor.y++;
      });
      Terminal.push_raw(s);
    }
    return this;
  };

  Terminal.flush = function() {
    Terminal.write(Terminal.buffer);
    Terminal.buffer = '';
    return this;
  };

  Terminal.get_clean = function() {
    var b;
    b = Terminal.buffer;
    Terminal.buffer = '';
    return b;
  };

  Terminal.ansi_esc = (function() {
    function _Class() {}

    _Class.cursor_pos = function(x, y) {
      return "\x1b[" + y + ";" + x + "H";
    };

    _Class.clear_screen = '\x1b[2J';

    _Class.clear_eol = '\x1b[K';

    _Class.clear_eof = '\x1b[J';

    _Class.color = (function() {
      function _Class() {}

      _Class.reset = '\x1b[0m';

      _Class.bold = '\x1b[1m';

      _Class.inverse = '\x1b[7m';

      _Class.strike = '\x1b[9m';

      _Class.unbold = '\x1b[22m';

      _Class.black = '\x1b[30m';

      _Class.red = '\x1b[31m';

      _Class.green = '\x1b[32m';

      _Class.yellow = '\x1b[33m';

      _Class.blue = '\x1b[34m';

      _Class.magenta = '\x1b[35m';

      _Class.cyan = '\x1b[36m';

      _Class.white = '\x1b[37m';

      _Class.xterm = function(i) {
        return "\x1b[38;5;" + i + "m";
      };

      _Class.bg_reset = '\x1b[49m';

      _Class.bg_black = '\x1b[40m';

      _Class.bg_red = '\x1b[41m';

      _Class.bg_green = '\x1b[42m';

      _Class.bg_yellow = '\x1b[43m';

      _Class.bg_blue = '\x1b[44m';

      _Class.bg_magenta = '\x1b[45m';

      _Class.bg_cyan = '\x1b[46m';

      _Class.bg_white = '\x1b[47m';

      _Class.bg_xterm = function(i) {
        return "\x1b[48;5;" + i + "m";
      };

      return _Class;

    })();

    return _Class;

  }).call(this);

  Terminal.clear = function() {
    return Terminal.push_raw(Terminal.ansi_esc.clear_screen);
  };

  Terminal.cursor = {
    x: null,
    y: null
  };

  Terminal.screen = {
    w: null,
    h: null
  };

  Terminal.go = function(x, y) {
    if (x < 1) {
      die("Terminal.cursor.x " + x + " may not be less than 1!");
    }
    if (x > Terminal.screen.w) {
      die("Terminal.cursor.x " + x + " may not be greater than Terminal.screen.w or " + Terminal.screen.w + "!");
    }
    Terminal.cursor.x = x;
    if (y < 1) {
      die("Terminal.cursor.y " + y + " may not be less than 1!");
    }
    if (y > Terminal.screen.h) {
      die("Terminal.cursor.y " + y + " may not be greater than Terminal.screen.h or " + Terminal.screen.h + "!");
    }
    Terminal.cursor.y = y;
    Terminal.push_raw(Terminal.ansi_esc.cursor_pos(Terminal.cursor.x, Terminal.cursor.y));
    return this;
  };

  Terminal.move = function(x, y) {
    var dx, dy;
    if (y == null) {
      y = 0;
    }
    dx = Terminal.cursor.x + x;
    dy = Terminal.cursor.y + y;
    if (dx >= 0 && dx <= Terminal.screen.w && dy >= 0 && dy <= Terminal.screen.h) {
      this.go(dx, dy);
    }
    return this;
  };

  Terminal.fg = function(color) {
    return Terminal.push_raw(Terminal.ansi_esc.color[color]);
  };

  Terminal.bg = function(color) {
    return Terminal.push_raw(Terminal.ansi_esc.color['bg_' + color]);
  };

  Terminal.xfg = function(i) {
    return Terminal.push_raw(Terminal.ansi_esc.color.xterm(i));
  };

  Terminal.xbg = function(i) {
    return Terminal.push_raw(Terminal.ansi_esc.color.bg_xterm(i));
  };

  Terminal.clear_screen = function() {
    var y, _i, _ref;
    Terminal.clear();
    for (y = _i = 1, _ref = Terminal.screen.h; 1 <= _ref ? _i <= _ref : _i >= _ref; y = 1 <= _ref ? ++_i : --_i) {
      Terminal.go(1, y);
      Terminal.clear_eol();
    }
    return this;
  };

  Terminal.clear_n = function(n) {
    return Terminal.echo(repeat(n, ' '));
  };

  Terminal.clear_eol = function() {
    return Terminal.clear_n(Terminal.screen.w - Terminal.cursor.x + 1);
  };

  Terminal.clear_space = function(o) {
    var y, _i, _ref, _ref1;
    for (y = _i = _ref = o.y, _ref1 = o.y + o.h - 1; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; y = _ref <= _ref1 ? ++_i : --_i) {
      Terminal.xbg(o.bg).go(o.x, y).clear_n(o.w);
    }
    Terminal.go(o.x, o.y).xbg(o.bg).xfg(o.fg).flush();
    return this;
  };

  return Terminal;

}).call(this);
