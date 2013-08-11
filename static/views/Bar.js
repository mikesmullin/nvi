// Generated by CoffeeScript 1.6.3
var Bar;

module.exports = Bar = (function() {
  function Bar(o) {
    this.bg = o.bg || die("Bar.bg must be specified!");
    this.fg = o.fg || die("Bar.fg must be specified!");
    this.text = o.text || '';
    this.resize({
      x: o.x,
      y: o.y,
      w: o.w,
      h: o.h
    });
    return;
  }

  Bar.prototype.resize = function(o) {
    if (o.x) {
      this.x = o.x;
    }
    if (this.x < 1) {
      die("Bar.x may not be less than 1!");
    }
    this.y = o.y;
    if (this.y < 1) {
      die("Bar.y may not be less than 1!");
    }
    this.w = o.w;
    if (this.w < 1) {
      die("Bar.w may not be less than 1!");
    }
    if (o.h) {
      this.h = o.h;
    }
    if (this.h < 1) {
      die("Bar.h may not be less than 1!");
    }
    this.draw();
  };

  Bar.prototype.draw = function() {
    this.set_text(this.text);
  };

  Bar.prototype.set_text = function(s, return_cursor) {
    var _ref;
    if (return_cursor == null) {
      return_cursor = true;
    }
    Terminal.clear_space({
      x: this.x,
      y: this.y,
      w: this.w,
      h: this.h,
      bg: this.bg,
      fg: this.fg
    }).echo(s.substr(0, this.w)).flush();
    this.text = s;
    if (return_cursor) {
      if ((_ref = Window.current_cursor()) != null) {
        _ref.draw();
      }
    }
  };

  return Bar;

})();
