MenuItem = require './menu-item'
MenuTreeView = require './menu-tree-view'
{Disposable} = require 'atom'
{$, ScrollView} = require 'atom-space-pen-views'

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
    #console.log 'MenuManagerView.@content'
    @div class: 'menu-manager pane-item', =>
      @button outlet: 'toggleAllButton', class: 'btn btn-toggle-all', 'Collapse/Expand All Sections'
      @section class: 'bordered intro', =>
        @h1 class: 'block section-heading icon icon-checklist', 'Menu Manager'
        @p 'Menu Manager shows main menu items and all context menu items from Atom.'
      @menuSection 'main-menu', 'Main Menu', getMainMenu, ->
        @h1 class: 'block section-heading icon icon-checklist', click: 'toggle', 'Main Menu'
        @p 'Double-click menu item to execute the command.'
        @ul outlet: 'noResultsElement', class: 'background-message centered', =>
          @li 'No Results'
        @div outlet: 'treeViewElement'
      @menuSection 'context-menu', 'Context Menu', getContextMenu, ->
        @h1 class: 'block section-heading icon icon-checklist', click: 'toggle', 'Context Menu'
        @p 'Double-click context-menu item to execute the command.'
        @ul outlet: 'noResultsElement', class: 'background-message centered', =>
          @li 'No Results'
        @div outlet: 'treeViewElement'

  @menuSections: {}
  @menuSection: (name, title, menu, contentFn) ->
    #console.log 'MenuManagerView.@menuSection', arguments
    MenuManagerView.menuSections[name] = new MenuTreeView(name, title, menu, contentFn)

  initialize: ({@uri}={}) ->
    super
    #console.log 'MenuManagerView.initialize', MenuManagerView.menuSections
    @append(section) for name, section of MenuManagerView.menuSections
    @toggleAllButton.on('click', @toggleAllSections)

  toggleAllSections: ->
    firstSection = MenuManagerView.menuSections[Object.keys(MenuManagerView.menuSections)[0]]
    @toggleAllSectionsState ?= if firstSection.isCollapsed() then 'collapse' else 'expand'
    @toggleAllSectionsState = if @toggleAllSectionsState is 'expand' then 'collapse' else 'expand'
    section[@toggleAllSectionsState]() for name, section of MenuManagerView.menuSections

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri
  getTitle: -> "Menu Manager"
  getIconName: -> "checklist"
  onDidChangeTitle: (cb) -> new Disposable ->
  onDidChangeModified: (cb) -> new Disposable ->
  isEqual: (other) -> other instanceof MenuManagerView
