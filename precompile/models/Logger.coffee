fs = require 'fs'
path = require 'path'

module.exports = class Logger
  @out: (s) ->
    fs.appendFileSync path.join(__dirname, '..', '..', 'nvi.log'), s+"\n"
    return
