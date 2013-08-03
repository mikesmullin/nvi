### TODO:
* arrow keys cursor movement
* lclick to place cursor
* lclick+drag to highlight
* double-lclick to highlight word
* triple-lclick to highlight line
###
module.exports = (nvi) ->
  logger.out 'will personalize'

  process.stdin.on 'keypress', (ch, key) =>
    switch key.name
      when 'left'
        @terminal.move -1
      when 'right'
        @terminal.move 1
      when 'up'
        @terminal.move 0, -1
      when 'down'
        @terminal.move 0, 1
