// Generated by CoffeeScript 1.6.3
var Cell, Tab;

Cell = require('./Cell');

module.exports = Tab = (function() {
  function Tab(o) {
    this.name = o.name || 'untitled';
    if (o.active) {
      Window.active_tab = this;
    }
    this.views = [];
    this.topmost_cell = new Cell({
      p: 1,
      chain: {
        x: this.x,
        y: this.y,
        w: this.w,
        h: this.ih
      }
    });
    this.resize({
      x: o.x,
      y: o.y,
      w: o.w,
      h: o.h
    });
    this.topmost_cell.new_view({
      tab: this,
      file: o.file,
      active: o.active
    });
  }

  Tab.prototype.destroy = function() {};

  Tab.prototype.resize = function(o) {
    if (o.x) {
      this.x = o.x;
    }
    if (this.x < 1) {
      die("Tab.x may not be less than 1!");
    }
    if (o.y) {
      this.y = o.y;
    }
    if (this.y < 1) {
      die("Tab.y may not be less than 1!");
    }
    this.w = o.w;
    if (this.w < 1) {
      die("Tab.w may not be less than 1!");
    }
    this.h = o.h;
    if (this.h < 1) {
      die("Tab.h may not be less than 1!");
    }
    this.ih = o.h;
    this.draw();
    this.topmost_cell.resize({
      chain: {
        x: this.x,
        y: this.y,
        w: this.w,
        h: this.ih
      }
    });
  };

  Tab.prototype.draw = function() {};

  Tab.prototype.activate_view = function(view) {
    var v, _i, _len, _ref;
    _ref = this.views;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      v = _ref[_i];
      v.active = v === view;
    }
  };

  Tab.prototype.split = function(cmd, file) {
    var divider_w, new_view;
    divider_w = 1;
    if (cmd === 'split') {
      cmd = 'hsplit';
    }
    new_view = this.active_view.cell[cmd]({
      tab: Window.active_tab,
      file: file
    });
    return this.activate_view(new_view);
  };

  return Tab;

})();
