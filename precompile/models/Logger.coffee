fs = require 'fs'
path = require 'path'

module.exports = class Logger
  @filename: 'nvi.log'
  @out: ->
    o = {}
    switch arguments.length
      when 2 then [o, s] = arguments
      when 1 then [s] = arguments
    o.type ||= 'info'

    out = "#{Date.create().format '{MM}/{dd}/{yy} {HH}:{mm}:{ss}.{fff}'} "+
      "#{if o.remote then "#{o.remote} " else ""}"+
      "[#{o.type}] "+
      "#{s}"+
      "#{if o.type is 'out' then "" else "\n"}"

    fs.appendFileSync path.join(__dirname, '..', '..', Logger.filename), out
    return
