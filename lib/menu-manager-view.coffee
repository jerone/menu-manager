{$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class MenuManagerView extends ScrollView
  @content: ->
    @div class: 'menu-manager', =>
      @button outlet: 'collapseAllButton', class: 'btn btn-collapse-all', 'Collapse All Sections'
      @section =>
        @h1 "Main Menu"
        @ul outlet: 'mainMenuNoResults', class: 'background-message centered', =>
          @li 'No Results'
        @ul outlet: 'mainMenuList', class: 'list-tree has-collapsable-children'
      @section =>
        @h1 "Context Menu"
        @ul outlet: 'contextMenuNoResults', class: 'background-message centered', =>
          @li 'No Results'
        @ul outlet: 'contextMenuList', class: 'list-tree has-collapsable-children'

  initialize: (state) ->
    super
    @mainMenuNoResults.remove() if atom.menu.template?.length > 0
    @subMenu @mainMenuList, atom.menu.template
    @contextMenuNoResults.remove() if atom.contextMenu.itemSets?.length > 0
    @subMenu @contextMenuList, atom.contextMenu.itemSets

  subMenu: (elm, menu) ->
    for menuItem in menu
      switch menuItem.type
        when 'separator' then listItemContent = $('<hr/>')
        else listItemContent = $('<span/>').html(menuItem.selector ? menuItem.label?.replace /&(\D)/, (match, group) -> "<u>#{group}</u>")

      if menuItem.submenu?.length > 0 or menuItem.items?.length > 0
        listItem = $('<li/>', class: 'list-nested-item').appendTo elm
        $('<div/>', class: 'list-item').append(listItemContent).appendTo listItem
        listTree = $('<ul/>', class: 'list-tree').appendTo listItem
        @subMenu(listTree, menuItem.submenu or menuItem.items)
      else
        $('<li/>', class: 'list-item').append(listItemContent).appendTo elm
