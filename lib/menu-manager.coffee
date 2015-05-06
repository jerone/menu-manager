MenuManagerPage = require './menu-manager-page'
{CompositeDisposable} = require 'atom'
{$$} = require 'atom-space-pen-views'

module.exports = MenuManager =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'menu-manager:toggle': ->
      atom.workspace.getActivePane().activateItem new MenuManagerPage()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
