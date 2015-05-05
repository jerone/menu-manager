MenuManagerView = require './menu-manager-view'

module.exports = 
class MenuManagerPane
  constructor: (@tabTitle) ->

  getTitle:     -> @tabTitle
  getViewClass: -> MenuManagerView
