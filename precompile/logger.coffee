fs = require 'fs'
path = require 'path'

module.exports = class logger
  @out: (s) ->
    fs.appendFile path.join(__dirname, '..', 'logs', 'nvi.log'), s+"\n", (err) ->
      throw err if err
