// Generated by CoffeeScript 1.6.3
var BufferViewCursor;

module.exports = BufferViewCursor = (function() {
  function BufferViewCursor(o) {
    this.user = o.user;
    this.view = o.view;
    this.possessed = o.possessed || false;
    this.resize({
      x: o.x,
      y: o.y,
      w: o.w,
      h: o.h
    });
    return;
  }

  BufferViewCursor.prototype.resize = function(o) {
    this.x = o.x;
    if (this.x < 1) {
      die("BufferViewCursor.x may not be less than 1!");
    }
    this.y = o.x;
    if (this.y < 1) {
      die("BufferViewCursor.y may not be less than 1!");
    }
    this.w = 1;
    if (this.w < 1) {
      die("BufferViewCursor.w may not be less than 1!");
    }
    this.h = 1;
    if (this.h < 1) {
      die("BufferViewCursor.h may not be less than 1!");
    }
    this.draw();
  };

  BufferViewCursor.prototype.go = function(x, y) {
    this.x = x;
    this.y = y;
    Logger.out("BufferView.cursor = x: " + this.x + ", y: " + this.y);
    Terminal.go(this.view.x + this.view.gutter.length + this.x - 1, this.view.y + this.y - 1).flush();
  };

  BufferViewCursor.prototype.move = function(x, y) {
    var dx, dy;
    if (y == null) {
      y = 0;
    }
    dx = this.x + x;
    dy = this.y + y;
    if (dx >= 1 && dx <= this.view.iw - this.view.gutter.length && dy >= 1 && dy <= this.view.ih) {
      this.go(dx, dy);
    }
  };

  BufferViewCursor.prototype.draw = function() {
    if (this.possessed) {
      this.move(0, 0);
    } else {

    }
  };

  return BufferViewCursor;

})();