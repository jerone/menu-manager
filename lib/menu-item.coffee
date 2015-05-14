module.exports =
class MenuItem
  constructor: ({@label, @selector, @command, @created, @type, @enabled, submenu, items}, fn) ->
    #console.log 'MenuItem.constructor', arguments
    @label ?= @selector
    if @command?
      @keystroke = atom.keymaps.findKeyBindings({
        @command
        target: @selector && document.querySelector(@selector)
      })?[0]?.keystrokes
    if submenu?.length > 0 or items?.length > 0
      @children = []
      for subItem in submenu or items
        subItem.selector ?= @selector
        @children.push new MenuItem subItem, fn
    fn?(@)
