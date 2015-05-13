# Altered verion of https://github.com/xndcn/symbols-tree-view/blob/8176f385f96650ae6f69fa0a52782376c0403939/lib/tree-view.coffee

{$, $$, View, ScrollView} = require 'atom-space-pen-views'
{Emitter} = require 'event-kit'

module.exports =
  TreeNode: class TreeNode extends View
    @content: ({label, icon, children, keystroke, type, command}, options={}) ->
      #console.log 'TreeNode.content', arguments
      icon ?= ''
      if children?.length
        @li class: 'list-nested-item list-selectable-item', =>
          @div class: 'list-item', =>
            @span class: 'pull-right key-binding', keystroke if keystroke
            if type is 'separator'
              @hr outlet: 'label'
            else
              @span outlet: 'label', class: "icon #{icon}", label
              @span class: 'status-ignored', " (#{command})" if command
          @ul class: 'list-tree', =>
            for child in children
              #console.log 'TreeNode.content 2', arguments, child, children
              @subview 'child', new TreeNode child, options
      else
        @li class: 'list-item list-selectable-item', =>
          @span class: 'pull-right key-binding', keystroke if keystroke
          if type is 'separator'
            @hr outlet: 'label'
          else
            @span outlet: 'label', class: "icon #{icon}", label
            @span class: 'status-ignored', " (#{command})" if command

    initialize: (item, options={}) ->
      #console.log 'TreeNode.initialize', arguments
      @emitter = new Emitter
      @item = item
      @item.view = this

      if options.useMnemonic and item.type isnt 'separator'
        #console.log 'TreeNode.initialize', item.label, arguments
        @label.html item.label?.replace /&(\D)/, (match, group) ->
          "<u>#{group}</u>"

      @on 'dblclick', @dblClickItem
      @on 'click', @clickItem

    setCollapsed: ->
      @toggleClass 'collapsed' if @item.children?.length

    setSelected: ->
      @addClass 'selected'

    onDblClick: (callback) ->
      @emitter.on 'on-dbl-click', callback
      if @item.children?.length
        for child in @item.children
          child.view.onDblClick callback

    onSelect: (callback) ->
      @emitter.on 'on-select', callback
      if @item.children?.length
        for child in @item.children
          child.view.onSelect callback

    clickItem: (event) =>
      if @item.children?.length
        selected = @hasClass 'selected'
        @removeClass 'selected'
        $target = @find '.list-item:first'
        left = $target.position().left
        right = $target.children('span').position().left
        width = right - left
        @toggleClass 'collapsed' if event.offsetX <= width
        @addClass 'selected' if selected
        return false if event.offsetX <= width

      @emitter.emit 'on-select', {node: @, @item}
      return false

    dblClickItem: (event) =>
      @emitter.emit 'on-dbl-click', {node: @, @item}
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
      @emitter.on 'on-select', callback

    onDblClick: (callback) =>
      @emitter.on 'on-dbl-click', callback

    setRoot: (root, ignoreRoot=false) ->
      rootNode = @rootNode = new TreeNode root, @options

      @rootNode.onDblClick ({node, item}) =>
        node.setCollapsed()
        @emitter.emit 'on-dbl-click', {node, item}
      @rootNode.onSelect ({node, item}) =>
        @clearSelect()
        node.setSelected()
        @emitter.emit 'on-select', {node, item}

      @root.empty()
      @root.append $$ ->
        @div =>
          if ignoreRoot
            if root.children?.length
              for child in root.children
                @subview 'child', child.view
          else
            @subview 'root', rootNode

    traversal: (root, doing) =>
      doing(root.item)
      if root.item.children?.length
        for child in root.item.children
          @traversal child.view, doing

    toggleTypeVisible: (type) =>
      @traversal @rootNode, (item) ->
        if item.type is type
          item.view.toggle()

    sortByName: (ascending=true) =>
      @traversal @rootNode, (item) ->
        item.children?.sort (a, b) ->
          if ascending
            return a.name.localeCompare b.name
          else
            return b.name.localeCompare a.name
      @setRoot @rootNode.item

    sortByRow: (ascending=true) =>
      @traversal @rootNode, (item) ->
        item.children?.sort (a, b) ->
          if ascending
            return a.position.row - b.position.row
          else
            return b.position.row - a.position.row
      @setRoot @rootNode.item

    clearSelect: ->
      $('.list-selectable-item').removeClass 'selected'

    select: (item) ->
      @clearSelect()
      item?.view.setSelected()
