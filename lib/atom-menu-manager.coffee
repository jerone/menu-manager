{Emitter} = require 'event-kit'
{debounce} = require './helpers'

module.exports = class AtomMenuManager
  constructor: ->
    @emitter = new Emitter

    @onUpdateDebounced =
      debounce((=>
        @emitter.emit 'on-update', arguments
      ), 1000)

    @overrideAtomMenu()
    @overrideAtomContextMenu()

  # atom.menu.add([{label: 'Hello', submenu : [{label: 'World!', command: 'hello:world'}]}])
  # atom.menu.update()
  overrideAtomMenu: ->
    tmp = atom.menu.update
    atom.menu.update = =>
      # console.log 'AtomMenuManager::overrideAtomMenu>atom.menu.update', arguments
      rtrn = tmp.apply atom.menu, arguments
      @onUpdateDebounced()
      rtrn

  # atom.contextMenu.add({'atom-workspace': [{label: 'Hello World!', command: 'hello:world'}]})
  overrideAtomContextMenu: ->
    tmp = atom.contextMenu.add
    atom.contextMenu.add = =>
      # console.log 'AtomMenuManager::overrideAtomContextMenu>atom.contextMenu.add', arguments
      rtrn = tmp.apply atom.contextMenu, arguments
      @onUpdateDebounced()
      rtrn

  onUpdate: (callback) =>
    # console.log 'AtomMenuManager::onUpdate', arguments
    @emitter.on 'on-update', callback

  dispose: ->
    @emitter.dispose()
