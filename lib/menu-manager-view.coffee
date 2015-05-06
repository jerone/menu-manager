MenuTreeView = require './menu-tree-view'
{$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class MenuManagerView extends ScrollView
  @content: ->
    @div class: 'menu-manager', =>
      @button outlet: 'collapseAllButton', class: 'btn btn-collapse-all', 'Collapse All Sections'

  initialize: (state) ->
    super
    @append new MenuTreeView(atom.menu.template, 'Main Menu')
    @append new MenuTreeView(atom.contextMenu.itemSets, 'Context Menu')
