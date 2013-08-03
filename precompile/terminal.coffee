module.exports = class terminal
  @echo: (s) -> process.stdout.write s; @
  @ctl: class # ansi escape sequences / control characters/codes
    constructor: (s) -> terminal.echo "\u001b"+s
    @CLEAR_SCREEN: '[2J'
    @CLEAR_EOL: '[K'
    @CLEAR_EOF: '[J'
    @POS: (x, y) -> "[#{y};#{x}H"
    @color: class
      # modifiers
      @reset       : '[0m'
      @bold        : '[1m'
      @inverse     : '[7m'
      @strike      : '[9m'
      @unbold      : '[22m'
      # foreground
      @black       : '[30m'
      @red         : '[31m'
      @green       : '[32m'
      @yellow      : '[33m'
      @blue        : '[34m'
      @magenta     : '[35m'
      @cyan        : '[36m'
      @white       : '[37m'
      @xterm       : (i) -> "[38;5;#{i}m"
      # background
      @bg_reset    : '[49m'
      @bg_black    : '[40m'
      @bg_red      : '[41m'
      @bg_green    : '[42m'
      @bg_yellow   : '[43m'
      @bg_blue     : '[44m'
      @bg_magenta  : '[45m'
      @bg_cyan     : '[46m'
      @bg_white    : '[47m'
      @bg_xterm     : (i) -> "[48;5;#{i}m"
  @clear: -> terminal.ctl terminal.ctl.CLEAR_SCREEN; @
  @go: (x,y) -> terminal.ctl terminal.ctl.POS x, y; @
  @fg: (color) -> terminal.ctl terminal.ctl.color[color]; @
  @bg: (color) -> terminal.ctl terminal.ctl.color['bg_'+color]; @
  @xfg: (i) -> terminal.ctl terminal.ctl.color.xterm i; @
  @xbg: (i) -> terminal.ctl terminal.ctl.color.bg_xterm i; @
