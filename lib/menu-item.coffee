module.exports =
class MenuItem
  constructor: (item) ->
    @icon = ''
    @label = getLabel item
    @command = item.command if item.command
    if item.submenu?.length > 0 or item.items?.length > 0
      @children = []
      for subItem in item.submenu or item.items
        @children.push new MenuItem subItem
  getLabel = (item) ->
    return '---' if item.type is 'separator'
    return item.selector if item.selector
    return item.label?.replace /&(\D)/, (match, group) ->
      "<u>#{group}</u>"
