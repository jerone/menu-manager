module.exports =
class MenuItem
  constructor: ({@label, @sublabel, @selector, @command, @created, @type, @enabled, @visible, @checked, @devMode, submenu, items}) ->
    #console.log 'MenuItem.constructor', arguments

    @label ?= @sublabel
    @label ?= @selector

    if @command?
      accelerator = acceleratorForCommand(@command, @selector)
      @keystroke = accelerator if accelerator?

    if submenu?.length > 0 or items?.length > 0
      @children = []
      for subItem in submenu or items
        subItem.selector ?= @selector
        @children.push(new MenuItem(subItem))

# https://github.com/atom/atom/blob/master/src/browser/application-menu.coffee#L160
acceleratorForCommand = (command, selector) ->
  binding = atom.keymaps.findKeyBindings
    command: command
    target: selector and document.querySelector(selector)
  keystroke = binding?[0]?.keystrokes
  return null unless keystroke

  modifiers = keystroke.split(/-(?=.)/)
  key = modifiers.pop().toUpperCase().replace('+', 'Plus')

  modifiers = modifiers.map (modifier) ->
    modifier.replace(/shift/ig, "Shift")
            .replace(/cmd/ig, "Command")
            .replace(/ctrl/ig, "Ctrl")
            .replace(/alt/ig, "Alt")

  keys = modifiers.concat([key])
  keys.join("+")
