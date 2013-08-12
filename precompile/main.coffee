[nil, nil, args...] = process.argv
Application = require './controllers/application'
global.App = new Application args: args
App.init()
