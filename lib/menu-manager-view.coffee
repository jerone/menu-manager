MenuItem = require './menu-item'
MenuTreeView = require './menu-tree-view'
{Disposable} = require 'atom'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class MenuManagerView extends ScrollView
  @deserialize: (state) ->
    new MenuManagerView(state)

  @content: ->
    #console.log 'MenuManagerView.@content'
    @div class: 'menu-manager pane-item', =>
      @button outlet: 'toggleAllButton', class: 'btn btn-toggle-all', 'Collapse/Expand All Sections'
      @section class: 'bordered', =>
        @h1 class: 'section-heading', 'Menu Manager'
        @p 'Menu Manager shows main menu items and all context menu items from Atom.'
      @menuSection 'main-menu', 'Main Menu', (new MenuItem item for item in atom.menu.template), ->
        @p 'Double-click item to execute the command.'
      @menuSection 'context-menu', 'Context Menu', (new MenuItem item for item in atom.contextMenu.itemSets), ->
        @p 'Double-click item to execute the command.'

  @menuSections: {}
  @menuSection: (name, title, menu, contentFn) ->
    #console.log 'MenuManagerView.@menuSection', arguments
    MenuManagerView.menuSections[name] = new MenuTreeView name, title, menu, contentFn

  initialize: ({@uri}={}) ->
    super
    #console.log 'MenuManagerView.initialize', MenuManagerView.menuSections
    @append(section) for name, section of MenuManagerView.menuSections
    @toggleAllButton.on 'click', @toggleAllSections

  toggleAllSections: ->
    @toggleAllSectionsState = if @toggleAllSectionsState is 'expand' then 'collapse' else 'expand'
    section[@toggleAllSectionsState]() for name, section of MenuManagerView.menuSections

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri
  getTitle: -> "Menu Manager"
  onDidChangeTitle: (cb) -> new Disposable ->
  onDidChangeModified: (cb) -> new Disposable ->
  isEqual: (other) -> other instanceof MenuManagerView
