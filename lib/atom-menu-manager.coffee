{Emitter} = require 'event-kit'

debounce = (func, wait, immediate) ->
  timeout = undefined
  ->
    context = this
    args = arguments

    later = ->
      timeout = null
      func.apply context, args unless immediate
      return

    callNow = immediate and not timeout
    clearTimeout timeout
    timeout = setTimeout(later, wait)
    func.apply context, args if callNow
    return

module.exports = class AtomMenuManager
  constructor: ->
    @emitter = new Emitter

    @onUpdateDebounced =
      debounce((=>
        @emitter.emit 'on-update', arguments
      ), 1000)

    @overrideAtomMenuAdd()
    @overrideAtomMenuUpdate()

  # atom.menu.add([{label: 'Hello', submenu : [{label: 'World!', command: 'hello:world'}]}])
  overrideAtomMenuAdd: ->
    tmp = atom.menu.add
    atom.menu.add = =>
      console.log 'AtomMenuManager::overrideAtomMenuAdd>atom.menu.add', arguments
      rtrn = tmp.apply atom.menu, arguments
      @onUpdateDebounced()
      rtrn

  # atom.menu.update()
  overrideAtomMenuUpdate: ->
    tmp = atom.menu.update
    atom.menu.update = =>
      console.log 'AtomMenuManager::overrideAtomMenuAdd>atom.menu.update', arguments
      rtrn = tmp.apply atom.menu, arguments
      @onUpdateDebounced()
      rtrn

  onUpdate: (callback) =>
    console.log 'AtomMenuManager::onUpdate', arguments
    @emitter.on 'on-update', callback

  dispose: ->
    @emitter.dispose()
