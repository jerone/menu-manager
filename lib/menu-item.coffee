module.exports =
class MenuItem
  constructor: ({@label, @selector, @command, @created, @type, submenu, items}) ->
    #console.log 'MenuItem.constructor', arguments
    @label ?= @selector
    #@label = '---' if type is 'separator'
    if submenu?.length > 0 or items?.length > 0
      @children = []
      for subItem in submenu or items
        subItem.selector ?= @selector
        @children.push new MenuItem subItem
