fs = require 'fs'
path = require 'path'

module.exports = class logger
  @out: (s) ->
    filename = path.join(__dirname, '..', 'logs', 'nvi.log')
    fs.appendFileSync filename, s+"\n"
