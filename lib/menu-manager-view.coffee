{$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class MenuManagerView extends ScrollView
  @content: ->
    @div class: 'menu-manager', =>
      @button outlet: 'collapseAllButton', class: 'btn btn-collapse-all', 'Collapse All Sections'
      @section =>
        @h1 "Menu Manager"
        @ul class: 'background-message centered', outlet: 'noresults', =>
          @li 'No Results'
        @ul class: 'list-tree has-collapsable-children', outlet: 'list'

  initialize: (state) ->
    super
    @noresults.remove() if atom.menu.template
    @submenu @list, atom.menu.template

  submenu: (elm, menu) ->
    for menuItem in menu
      switch menuItem.type
        when 'separator' then listItemContent = $('<hr/>')
        else listItemContent = $('<span/>').html(menuItem.label?.replace /&(\D)/, (match, group) -> "<u>#{group}</u>")

      if menuItem.submenu?.length > 0
        listItem = $('<li/>', class: 'list-nested-item').appendTo elm
        $('<div/>', class: 'list-item').append(listItemContent).appendTo listItem
        listTree = $('<ul/>', class: 'list-tree').appendTo listItem
        @submenu(listTree, menuItem.submenu)
      else
        $('<li/>', class: 'list-item').append(listItemContent).appendTo elm
