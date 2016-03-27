{CompositeDisposable} = require 'atom'
MenuManagerURI = 'atom://menu-manager'

createMenuManagerView = (state) ->
  MenuManagerView = require './menu-manager-view'
  new MenuManagerView(state)

atom.deserializers.add
  name: 'MenuManagerView'
  deserialize: (state) -> createMenuManagerView(state)

module.exports =
  config:
    showButton:
      type: 'boolean'
      default: true

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.addOpener (uri) ->
      createMenuManagerView({uri}) if uri is MenuManagerURI
    @subscriptions.add atom.commands.add 'atom-workspace', 'menu-manager:show', ->
      atom.workspace.open(MenuManagerURI)
    @subscriptions.add atom.config.onDidChange 'menu-manager.showButton', ({newValue}) =>
      if newValue then @showButton() else @removeButton()

  deactivate: ->
    @removeButton()
    @subscriptions.dispose()

  consumeToolBar: (toolBar) ->
    @toolBar = toolBar('menu-manager')
    @showButton() if atom.config.get('menu-manager.showButton')

  showButton: ->
    @toolBar?.addButton
      icon: 'checklist'
      callback: 'menu-manager:show'
      tooltip: 'Menu Manager'

  removeButton: ->
    @toolBar?.removeItems()
