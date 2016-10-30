MenuItem = require './menu-item'
MenuTreeView = require './menu-tree-view'
AtomMenuManager = require './atom-menu-manager'
{Disposable} = require 'atom'
{$, ScrollView} = require 'atom-space-pen-views'

timeAgoFromMs = (ms) ->
  sec = Math.round(ms / 1000)
  min = Math.round(sec / 60)
  hr = Math.round(min / 60)
  day = Math.round(hr / 24)
  month = Math.round(day / 30)
  year = Math.round(month / 12)
  if ms < 0
    'just now'
  else if sec < 10
    'just now'
  else if sec < 45
    sec + ' seconds ago'
  else if sec < 90
    'a minute ago'
  else if min < 45
    min + ' minutes ago'
  else if min < 90
    'an hour ago'
  else if hr < 24
    hr + ' hours ago'
  else if hr < 36
    'a day ago'
  else if day < 30
    day + ' days ago'
  else if day < 45
    'a month ago'
  else if month < 12
    month + ' months ago'
  else if month < 18
    'a year ago'
  else
    year + ' years ago'

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
      @button outlet: 'toggleAllButton', class: 'btn btn-toggle-all', 'Collapse/Expand All Sections'
      @section class: 'bordered intro', =>
        @h1 class: 'block section-heading icon icon-checklist', =>
          @raw 'Menu Manager'
          @span outlet: 'lastChecked', class: 'last-checked badge', title: new Date(), 'Last checked: just now'
        @p 'Menu Manager shows main menu items and all context menu items from Atom.'
      MenuManagerView.buildMenuSections.call(@)

  @buildMenuSections: ->
    # console.log 'MenuManagerView.buildHTML', arguments, this
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
    # console.log 'MenuManagerView.initialize', MenuManagerView.menuSections
    super

    @append(section) for name, section of MenuManagerView.menuSections
    @updateLastChecked()
    setInterval(@updateLastCheckedElement.bind(this), 60 * 1000)

    @toggleAllButton.on('click', @toggleAllSections)

    process.nextTick =>
      @atomMenuManager = new AtomMenuManager()
      @atomMenuManager.onUpdate =>
        # console.log 'MenuManagerView.atomMenuManager.onUpdate', arguments
        section.remove() for name, section of MenuManagerView.menuSections
        MenuManagerView.menuSections = []
        MenuManagerView.render.call(MenuManagerView, MenuManagerView.buildMenuSections)
        @append(section) for name, section of MenuManagerView.menuSections
        @updateLastChecked()
        @updateLastCheckedElement()

  toggleAllSections: ->
    firstSection = MenuManagerView.menuSections[Object.keys(MenuManagerView.menuSections)[0]]
    @toggleAllSectionsState ?= if firstSection.isCollapsed() then 'collapse' else 'expand'
    @toggleAllSectionsState = if @toggleAllSectionsState is 'expand' then 'collapse' else 'expand'
    section[@toggleAllSectionsState]() for name, section of MenuManagerView.menuSections

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
