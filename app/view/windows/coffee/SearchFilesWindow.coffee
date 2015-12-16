Ext.define 'FM.view.windows.SearchFilesWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.grids.FileSearchList'
    'FM.view.forms.SearchFileForm'
  ]
  alias: 'widget.search-files-window'
  cls: 'fm-search-files-window'
  title: t("Search Files")
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
      xtype: 'search-file-form'
    },
    {
      xtype: 'file-search-list'
    }
  ],
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

        Ext.ComponentQuery.query('textfield[name=search-file-path]', @)[0].setValue(@session.path)

    resize:
      fn: () ->
        FM.Logger.debug("SearchFilesWindow resize()", arguments)
        grid = Ext.ComponentQuery.query('file-search-list', @)[0]

        h = @getHeight()
        grid.setHeight(h-335)

  initComponent: () ->
    FM.Logger.debug('SearchFilesWindow initComponent()', @, arguments)

    @search_btn = Ext.create 'Ext.button.Button',
      handler: (button, e) =>
        FM.Logger.debug("Search files Search handler called()", arguments, @)
        if @search?
          filename = Ext.ComponentQuery.query('textfield[name=search-file-name]', @)[0].getValue()
          path = Ext.ComponentQuery.query('textfield[name=search-file-path]', @)[0].getValue()

          type_file = Ext.ComponentQuery.query('checkbox[name=search-type-file]', @)[0].getValue()
          type_dir = Ext.ComponentQuery.query('checkbox[name=search-type-dir]', @)[0].getValue()

          file_size = parseInt(Ext.ComponentQuery.query('textfield[name=search-file-size]', @)[0].getValue())
          file_size = if isNaN(file_size) then 0 else file_size*1024*1024 # mb -> bytes

          size_direction = Ext.ComponentQuery.query('combobox[name=search-file-size-direction]', @)[0].getValue()

          @search button, @, e,
            filename: filename
            path: path
            type_file: type_file
            type_dir: type_dir
            file_size: file_size
            size_direction: size_direction

      scope: @
      text: t("Search")
      ctrl: true
      enter: true

    @cancel_btn = Ext.create 'Ext.button.Button',
      handler: (button, e) =>
        FM.Logger.debug("Search files Cancel handler called()", arguments, @)
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
        FM.Logger.debug("Search files Close handler called()", arguments, @)
        @close()
      scope: @
      text: t("Close")

    @buttons = [@search_btn, @cancel_btn, @close_btn ]
    @preset = [@search_btn, @close_btn, @cancel_btn]  # <-- WTF @buttons is null after init, so will use @preset

    FM.Logger.debug('SearchFilesWindow init done', @, @buttons, @preset)
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

  getOperationStatus: () ->
    return @operationStatus