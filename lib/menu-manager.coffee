{CompositeDisposable} = require 'atom'
MenuManagerURI = 'atom://menu-manager'

createMenuManagerView = (state) ->
  MenuManagerView = require './menu-manager-view'
  new MenuManagerView(state)

atom.deserializers.add
  name: 'MenuManagerView'
  deserialize: (state) -> createMenuManagerView(state)

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.addOpener (uri) ->
      createMenuManagerView({uri}) if uri is MenuManagerURI
    @subscriptions.add atom.commands.add 'atom-workspace', 'menu-manager:show', ->
      atom.workspace.open(MenuManagerURI)

  deactivate: ->
    @subscriptions.dispose()
