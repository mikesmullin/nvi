fs = require 'fs'
path = require 'path'

module.exports = class Logger
  @out: (s) ->
    filename = path.join(__dirname, '..', 'nvi.log')
    fs.appendFileSync filename, s+"\n"
