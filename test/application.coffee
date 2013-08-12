assert = require('chai').assert
Application = require '../precompile/controllers/application'

describe 'Application', ->
  before ->
    global.App = new Application
      headless_display_file: 'nvi-display.log'
    App.init()

  after ->
    App.destroy dont_clear: true
    global.App = null

  it 'can print screen to file from inside tests', ->
    # i.e., in one window: `npm test` # mocha watch loop
    #       in another: `tailf nvi-display.log`
    #       continue editing files and watch realtime output
    assert.isDefined App.Window.active_tab.active_view
