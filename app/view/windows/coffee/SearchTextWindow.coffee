Ext.define 'FM.view.windows.SearchTextWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.grids.FileSearchList'
    'FM.view.forms.SearchTextForm'
  ]
  alias: 'widget.search-text-window'
  cls: 'fm-search-text-window'
  title: t("Search Text In Files")
  animate: true
  constrain: true
  layout: 'anchor'
  bodyPadding: '0 0 20 0'
  width: 600
  height: 450
  resizable:
    handles: 's n'
    minHeight: 300
    maxHeight: 900
  maximizable: true
  modal: false
  border: false
  operationStatus: null
  items: [
    {
      xtype: 'search-text-form'
    },
    {
      xtype: 'file-search-list'
    }
  ]
  listeners:
    show:
      fn: () ->
        if @keymap?
          @keymap.destroy()

        @keymap = new Ext.util.KeyMap
          target: @getEl()
          binding: [
            {
              key: Ext.event.Event.ENTER
              ctrl: true
              fn: FM.HotKeys.HotKeyDecorator (key, e) =>
                for button in @preset
                  if button.enter? and button.enter and button.ctrl? and button.ctrl and not button.isDisabled()
                    if button.handler?
                      button.handler(button, e)
                e.stopEvent()
            }
          ]

        Ext.ComponentQuery.query('textfield[name=search-text-path]', @)[0].setValue(@session.path)
        @updateSearchFilterState(true)

    resize:
      fn: () ->
        FM.Logger.debug("SearchTextWindow resize()", arguments)
        grid = Ext.ComponentQuery.query('file-search-list', @)[0]

        h = @getHeight()
        grid.setHeight(h-295)

  fileListStore: null

  initComponent: () ->
    @search_btn = Ext.create 'Ext.button.Button',
      handler: (button, e) =>
        FM.Logger.debug("Search text handler called()", arguments, @)
        if @search?
          text = Ext.ComponentQuery.query('textfield[name=search-file-text]', @)[0].getValue()
          path = Ext.ComponentQuery.query('textfield[name=search-text-path]', @)[0].getValue()

          @search button, @, e,
            text: text
            path: path

      scope: @
      text: t("Search")
      ctrl: true
      enter: true

    @cancel_btn = Ext.create 'Ext.button.Button',
      handler: (button, e) =>
        FM.Logger.debug("Search text Cancel handler called()", arguments, @)
        @cancelled = true
        if @cancel?
          @cancel(button, @, e, @getOperationStatus())
        else
          @close()
      scope: @
      text: t("Cancel")
      disabled: false
      hidden: true

    @close_btn = Ext.create 'Ext.button.Button',
      handler: () =>
        FM.Logger.debug("Search text Close handler called()", arguments, @)
        @close()
      scope: @
      text: t("Close")

    @buttons = [@search_btn, @cancel_btn, @close_btn ]
    @preset = [@search_btn, @close_btn, @cancel_btn]  # <-- WTF @buttons is null after init, so will use @preset

    @callParent(arguments)

  setSession: (session) ->
    @session = session

  getSession: () ->
    return @session

  hasSession: () ->
    return if @session? then true else false

  setOperationStatus: (status) ->
    @operationStatus = status

  hasOperationStatus: () ->
    return if @operationStatus? then true else false

  updateSearchFilterState: (state) ->
    searchFilter = Ext.ComponentQuery.query('searchfield[name=search-text-filter]', @)[0]
    searchFilter.setDisabled(state)


  getOperationStatus: () ->
    return @operationStatus