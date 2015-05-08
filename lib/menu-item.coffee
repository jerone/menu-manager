module.exports =
class MenuItem
  constructor: (item, selector=null) ->
    @icon = ''
    @label = if item.type is 'separator' then '---' else item.selector ? item.label
    @selector = item.selector ? selector
    @command = item.command if item.command
    @created = item.created if item.created
    if item.submenu?.length > 0 or item.items?.length > 0
      @children = []
      @children.push new MenuItem subItem, @selector for subItem in item.submenu or item.items
