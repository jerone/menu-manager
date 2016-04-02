# Altered verion of https://github.com/xndcn/symbols-tree-view/blob/8176f385f96650ae6f69fa0a52782376c0403939/lib/tree-view.coffee

{$, $$, View, ScrollView} = require 'atom-space-pen-views'
{Emitter} = require 'event-kit'

module.exports =
  TreeNode: class TreeNode extends View
    @content: ({label, sublabel, icon, children, keystroke, type, command, enabled, visible, checked, devMode}, options={}) ->
      #console.log 'TreeNode.content', arguments
      @li class: (if children?.length then 'list-nested-item ' else 'list-item ') + 'list-selectable-item' + (if sublabel then ' two-lines' else ''), =>
        @div class: (if children?.length then 'list-item' else ''), =>
          @span class: 'primary-line', =>
            @span class: 'pull-right key-binding', keystroke if keystroke
            if type is 'separator'
              @hr outlet: 'label'
            else
              @span class: 'menu-manager-ionicons ion-android-radio-button-off' if type is 'radio' and not checked
              @span class: 'menu-manager-ionicons ion-android-radio-button-on' if type is 'radio' and checked
              @span class: "icon #{icon}" if icon
              @span outlet: 'label', label
              @span class: 'text-subtle', "(#{command})" if command
              @span class: 'highlight', 'Readonly' if enabled is false
              @span class: 'highlight-info', 'Hidden' if visible is false
              @span class: 'highlight-error', 'DEV' if devMode is true
          if sublabel
            @span class: 'secundary-line text-subtle text-smaller', sublabel
        if children?.length
          @ul class: 'list-tree', =>
            for child in children
              #console.log 'TreeNode.content 2', arguments, child, children
              @subview 'child', new TreeNode(child, options)

    initialize: (item, options={}) ->
      #console.log 'TreeNode.initialize', arguments
      @emitter = new Emitter
      @item = item
      @item.view = this

      if options.useMnemonic and item.type isnt 'separator'
        #console.log 'TreeNode.initialize', item.label, arguments
        if typeof item.label is 'string' and item.label isnt ''
          @label.html item.label.replace /&(\D)/, (match, group) ->
            "<u>#{group}</u>"
        else @label.html '<i>&lt;no label&gt;</i>'

      @on('mousedown', @clickItem)
      @on('dblclick', @dblClickItem)
      atom.commands.add(@element, 'menu-manager:copy', @copyItem)

    setCollapsed: ->
      @toggleClass('collapsed') if @item.children?.length

    setSelected: ->
      @addClass('selected')

    onSelect: (callback) ->
      @emitter.on('on-select', callback)
      if @item.children?.length
        for child in @item.children
          child.view.onSelect(callback)

    onDblClick: (callback) ->
      @emitter.on('on-dbl-click', callback)
      if @item.children?.length
        for child in @item.children
          child.view.onDblClick(callback)

    onCopy: (callback) ->
      @emitter.on('on-copy', callback)
      if @item.children?.length
        for child in @item.children
          child.view.onCopy(callback)

    clickItem: (event) =>
      # console.log 'TreeNode.clickItem', event
      if @item.children?.length and event.which isnt 3
        selected = @hasClass('selected')
        @removeClass('selected') # Remove class to make collapse/expand work
        $target = @find('.list-item:first')
        left = $target.position().left
        right = $target.children('span').position().left
        width = right - left
        @toggleClass('collapsed') if event.offsetX <= width
        @addClass('selected') if selected
        return false if event.offsetX <= width

      @emitter.emit('on-select', {node: @, @item})
      return false

    dblClickItem: (event) =>
      @emitter.emit('on-dbl-click', {node: @, @item})
      return false

    copyItem: (event) =>
      #console.log 'TreeNode.copyItem', arguments, this
      @emitter.emit('on-copy', {node: @, @item})
      event.stopPropagation()
      return false


  TreeView: class TreeView extends ScrollView
    @content: ->
      @div class: '-tree-view-', =>
        @ul class: 'list-tree has-collapsable-children', outlet: 'root'

    initialize: (@options={}) ->
      super
      @emitter = new Emitter

    deactivate: ->
      @remove()

    onSelect: (callback) =>
      @emitter.on('on-select', callback)

    onDblClick: (callback) =>
      @emitter.on('on-dbl-click', callback)

    onCopy: (callback) =>
      @emitter.on('on-copy', callback)

    setRoot: (root, ignoreRoot=false) ->
      @rootNode = new TreeNode(root, @options)

      @rootNode.onDblClick ({node, item}) =>
        node.setCollapsed()
        @emitter.emit('on-dbl-click', {node, item})
      @rootNode.onSelect ({node, item}) =>
        @clearSelect()
        node.setSelected()
        @emitter.emit('on-select', {node, item})
      @rootNode.onCopy ({node, item}) =>
        @emitter.emit('on-copy', {node, item})

      @root.empty()
      @root.append $$ ->
        @div =>
          if ignoreRoot
            if root.children?.length
              for child in root.children
                @subview('child', child.view)
          else
            @subview('root', root.view)

    traversal: (root, doing) =>
      doing(root.item)
      if root.item.children?.length
        for child in root.item.children
          @traversal(child.view, doing)

    toggleTypeVisible: (type) =>
      @traversal @rootNode, (item) ->
        if item.type is type
          item.view.toggle()

    sortByName: (ascending=true) =>
      @traversal @rootNode, (item) ->
        item.children?.sort (a, b) ->
          if ascending
            return a.name.localeCompare(b.name)
          else
            return b.name.localeCompare(a.name)
      @setRoot(@rootNode.item)

    sortByRow: (ascending=true) =>
      @traversal @rootNode, (item) ->
        item.children?.sort (a, b) ->
          if ascending
            return a.position.row - b.position.row
          else
            return b.position.row - a.position.row
      @setRoot(@rootNode.item)

    clearSelect: ->
      $('.list-selectable-item').removeClass('selected')

    select: (item) ->
      @clearSelect()
      item?.view.setSelected()
