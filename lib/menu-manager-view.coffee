MenuTreeView = require './menu-tree-view'
{TreeView} = require './tree-view'
{$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class MenuManagerView extends ScrollView
  @content : ->
    @div class : 'menu-manager', =>
      @button outlet : 'collapseAllButton', class : 'btn btn-collapse-all', 'Collapse All Sections'
  initialize : (state) ->
    #super
    @treeView = new TreeView
    @append(@treeView)
    @treeView.onSelect ({node, item}) ->
      console.log arguments
    @treeView.setRoot({
      label : 'test',
      icon : 'icon-file-directory',
      children : [{
        label : 'test2',
        icon : 'icon-file-directory',
        children : [{
          label : 'test3',
          icon : ''
        }]
      }]
    })
