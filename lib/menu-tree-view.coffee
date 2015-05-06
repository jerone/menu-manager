{$, View} = require 'atom-space-pen-views'

module.exports =
class MenuTreeView extends View
  @content : ->
    @section =>
      @h1 outlet : 'title'
      @ul outlet : 'noResults', class : 'background-message centered', =>
        @li 'No Results'
      @ul outlet : 'list', class : 'list-tree has-collapsable-children'

  constructor : (menu, title) ->
    super
    @title.text title
    hasResults = menu.submenu?.length > 0 or menu.items?.length > 0
    @noResults.toggle(hasResults)
    @list.toggle(not hasResults)
    @subMenu menu, @list

  subMenu : (menu, elm) ->
    for menuItem in menu
      switch menuItem.type
        when 'separator' then listItemContent = $('<hr/>')
        else listItemContent = $('<span/>').html(menuItem.selector ? menuItem.label?.replace(/&(\D)/, (match, group) -> "<u>#{group}</u>"))
      if menuItem.submenu?.length > 0 or menuItem.items?.length > 0
        listItem = $('<li/>', class : 'list-nested-item').appendTo elm
        $('<div/>', class : 'list-item').append(listItemContent).appendTo listItem
        listTree = $('<ul/>', class : 'list-tree').appendTo listItem
        @subMenu menuItem.submenu or menuItem.items, listTree
      else
        $('<li/>', class : 'list-item').append(listItemContent).appendTo elm
