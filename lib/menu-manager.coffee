MenuManagerPane = require './menu-manager-pane'
{CompositeDisposable} = require 'atom'
{$$} = require 'atom-space-pen-views'

module.exports = MenuManager =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'menu-manager:toggle': ->
      atom.workspace.getActivePane().activateItem new MenuManagerPane "Menu Manager"

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
