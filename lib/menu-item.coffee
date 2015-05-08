module.exports =
class MenuItem
  constructor: (item) ->
    @icon = ''
    @label = if item.type is 'separator' then '---' else item.selector ? item.label
    @command = item.command if item.command
    if item.submenu?.length > 0 or item.items?.length > 0
      @children = []
      @children.push new MenuItem subItem for subItem in item.submenu or item.items
