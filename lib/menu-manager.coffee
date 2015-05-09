MenuManagerPage = require './menu-manager-page'
{CompositeDisposable} = require 'atom'
{$$} = require 'atom-space-pen-views'

module.exports = MenuManager =
  subs: null

  activate: (state) ->
    @subs = new CompositeDisposable
    @subs.add atom.commands.add 'atom-workspace', 'menu-manager:toggle': ->
      atom.workspace.getActivePane().activateItem new MenuManagerPage()

  deactivate: ->
    @subs.dispose()

  serialize: ->
