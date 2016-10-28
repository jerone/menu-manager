{Emitter} = require 'event-kit'

module.exports = class AtomMenuManager
  constructor: ->
    @emitter = new Emitter
    @overrideAtomMenuAdd()

  overrideAtomMenuAdd: ->
    add = atom.menu.add
    atom.menu.add = =>
      console.log 'AtomMenuManager|atom.menu.add', arguments
      add.apply atom.menu, arguments
      @emitter.emit 'on-update', {}
    # atom.menu.add([{label: 'Hello', submenu : [{label: 'World!', command: 'hello:world'}]}])

  onUpdate: (callback) =>
    @emitter.on 'on-update', callback

  dispose: ->
    @emitter.dispose()
