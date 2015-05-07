{$, View} = require 'atom-space-pen-views'
{TreeView} = require './tree-view'

module.exports =
class MenuTreeView extends View
  @content : ->
    @section =>
      @h1 outlet : 'title'
      @ul outlet : 'noResults', class : 'background-message centered', =>
        @li 'No Results'

  constructor : (menu, title) ->
    super
    @title.text title
    @noResults.toggle menu.length is 0

    root =
      label : title
      icon : 'icon-file-directory'
      children : []
    root.children.push item for item in menu

    @treeView = new TreeView {useMnemonic:true}
    @append @treeView
    @treeView.setRoot root
    @treeView.onDblClick ({node, item}) ->
      console.log arguments
      if item.command
        activeElement = document.activeElement
        # Use the workspace element view if body has focus
        if activeElement is document.body and workspaceElement = atom.views.getView(atom.workspace)
          activeElement = workspaceElement
        atom.commands.dispatch activeElement, item.command
