{$, View} = require 'atom-space-pen-views'
{TreeView} = require './tree-view'

module.exports =
class MenuTreeView extends View
  @content: (name, title, menuFn, contentFn) ->
    #console.log 'MenuTreeView.@content', arguments
    @section class: 'bordered', 'data-name': name, => contentFn.call(this)

  constructor: (name, title, menuFn, contentFn) ->
    super
    #console.log 'MenuTreeView.constructor', arguments, this
    (@treeViewElement or @).append(@treeView = new TreeView(useMnemonic: true))
    @treeView.onDblClick ({item, node}) =>
      #console.log 'MenuTreeView.@treeView.onDblClick', arguments, item.selector
      return if item.type is 'separator'
      if item.command and selector = @getActiveElement(item, node)
        item.created.call(item) if item.created
        atom.commands.dispatch(selector, item.command, item.commandDetail)
    @treeView.onCopy ({item, node}) ->
      #console.log 'MenuTreeView.@treeView.onCopy', arguments
      clone = ({label, sublabel, selector, command, keystroke, type, enabled, visible, checked, devMode, children}) ->
        cloned = {label, sublabel, selector, command, keystroke, type, enabled, visible, checked, devMode}
        cloned.children = (clone(child) for child in children) if children?.length
        cloned
      copy = clone(item)
      text = JSON.stringify(copy, null, '  ')
      atom.clipboard.write(text)
    process.nextTick =>
      menu = menuFn()
      @noResultsElement?.toggle(menu.length is 0)
      @treeView.setRoot
        label: title,
        icon: 'icon-file-directory',
        children: (item for item in menu)
      child.view.setCollapsed() for child in @treeView.rootNode.item.children

  getActiveElement: (item, node) ->
    console.log('MenuTreeView.getActiveElement', arguments, item.selector, node.parentView?.item?.selector)
    if selector = item.selector
      document.querySelector(selector)
    else if selector = node.parentView?.item?.selector
      document.querySelector(selector)
    else
      # https://github.com/atom/atom/blob/master/src/window-event-handler.coffee#L45-L51
      activeElement = document.activeElement
      if activeElement is document.body and workspaceElement = atom.views.getView(atom.workspace)
        activeElement = workspaceElement
      activeElement

  isCollapsed: ->
    @hasClass('collapsed')

  toggle: =>
    if @isCollapsed()
      @expand()
    else
      @collapse()

  collapse: =>
    @addClass('collapsed')

  expand: =>
    @removeClass('collapsed')
