MenuItem = require './menu-item'
MenuTreeView = require './menu-tree-view'
AtomMenuManager = require './atom-menu-manager'
{timeAgoFromMs} = require './helpers'
{Disposable} = require 'atom'
{$, ScrollView} = require 'atom-space-pen-views'

# https://github.com/atom/atom/blob/e5cfc6b6e4b36b6c443c0526bfb4c816c666b0f2/src/main-process/application-menu.coffee#L86-L88
substituteVersion = (item) ->
  item.label = "Version #{atom.appVersion}" if item.label is 'VERSION'
  substituteVersion(subitem) for subitem in item.children if item.children?.length
  item

getMainMenu = ->
  menu = (new MenuItem(item) for item in atom.menu.template)
  substituteVersion(item) for item in menu

getContextMenu = ->
  new MenuItem(item) for item in atom.contextMenu.itemSets

module.exports = class MenuManagerView extends ScrollView
  @deserialize: (state) ->
    new MenuManagerView(state)

  @content: ->
    # console.log 'MenuManagerView.@content', arguments, this
    @div class: 'menu-manager pane-item', =>
      @button outlet: 'toggleAllButton', class: 'btn btn-toggle-all', click: 'toggleAllSections', 'Collapse/Expand All Sections'
      @header class: 'menu-manager-header', =>
        @h1 class: 'icon icon-checklist', =>
          @raw 'Menu Manager'
          @span outlet: 'lastChecked', class: 'last-checked badge', title: new Date(), 'Last checked: just now'
        @p 'Menu Manager shows application menu items and context menu items from Atom.'
      @main class: 'menu-manager-sections', =>
        @subview 'application-menu', new MenuTreeView 'application-menu', 'Application Menu', getMainMenu, ->
          @h1 class: 'section-heading', click: 'toggle', 'Application Menu'
          @p 'Double-click an application menu item to execute the corresponding command.'
          @ul outlet: 'noResultsElement', class: 'background-message centered', =>
            @li 'No Results'
          @div outlet: 'treeViewElement', class: 'menu-tree-view'
        @subview 'context-menu', new MenuTreeView 'context-menu', 'Context Menu', getContextMenu, ->
          @h1 class: 'section-heading', click: 'toggle', 'Context Menu'
          @p 'Double-click a context menu item to execute the corresponding command.'
          @ul outlet: 'noResultsElement', class: 'background-message centered', =>
            @li 'No Results'
          @div outlet: 'treeViewElement', class: 'menu-tree-view'

  initialize: ({@uri}={}) ->
    # console.log 'MenuManagerView.initialize', arguments, this
    super

    @updateLastChecked()
    setInterval @updateLastCheckedElement.bind(this), 40 * 1000

    process.nextTick =>
      new AtomMenuManager().onUpdate =>
        # console.log 'MenuManagerView.atomMenuManager.onUpdate', arguments
        section.update() for section in @getAllSections()
        @updateLastChecked()
        @updateLastCheckedElement()

  getAllSections: ->
    [@['application-menu'], @['context-menu']]

  toggleAllSections: ->
    sections = @getAllSections()
    @toggleAllSectionsState ?= if sections[0].isCollapsed() then 'collapse' else 'expand'
    @toggleAllSectionsState = if @toggleAllSectionsState is 'expand' then 'collapse' else 'expand'
    section[@toggleAllSectionsState]() for section in sections

  updateLastChecked: ->
    @lastCheckedDate = new Date().getTime()

  updateLastCheckedElement: ->
    ms = new Date().getTime() - @lastCheckedDate
    @lastChecked.text 'Last checked: ' + timeAgoFromMs(ms)
    @lastChecked.attr 'title', new Date(ms)

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri
  getTitle: -> "Menu Manager"
  getIconName: -> "checklist"
  onDidChangeTitle: (cb) -> new Disposable ->
  onDidChangeModified: (cb) -> new Disposable ->
  isEqual: (other) -> other instanceof MenuManagerView
