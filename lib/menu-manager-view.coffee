MenuItem = require './menu-item'
MenuTreeView = require './menu-tree-view'
{$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class MenuManagerView extends ScrollView
  @content: ->
    @div class: 'menu-manager', =>
      @button outlet: 'collapseAllButton', class: 'btn btn-collapse-all', 'Collapse All Sections'

  initialize: (state) ->
    mainMenus = []
    mainMenus.push new MenuItem item for item in atom.menu.template
    @append new MenuTreeView mainMenus, 'Main Menu'
    contextMenus = []
    contextMenus.push new MenuItem item for item in atom.contextMenu.itemSets
    @append new MenuTreeView contextMenus, 'Context Menu'
