Ext.define 'FM.view.grids.WebDavConnectionList',
  extend: 'Ext.grid.Panel'
  alias: 'widget.webdav-connection-list'
  cls: 'fm-webdav-connection-list'
  columns: []
  stateful: true   ## <-- ???
  multiSelect: false
  tbar:
    xtype: 'webdav-connection-list-top-toolbar'
  viewConfig:
    stripeRows: false
  plugins: [
    Ext.create "Ext.ux.grid.plugin.RowEditing",
      clicksToMoveEditor: 1
      clicksToEdit: 0
      autoCancel: true
  ]
  requires: [
    'FM.view.toolbars.WebDavConnectionListTopToolbar'
    'FM.model.WebDavConnection'

    'Ext.ux.grid.plugin.RowEditing'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.grids.WebDavConnectionList init')
    @callParent(arguments)

    @initGridConfig()
    @initHandlers()

    @setStore(FM.Stores.WebDavConenctions)

  initHandlers: () ->
    panel = @

    do (panel) ->
      gridView = panel.getView()
      selection = gridView.getSelectionModel()

      toolbar  = Ext.ComponentQuery.query('webdav-connection-list-top-toolbar', panel)[0]
      dialog = toolbar.findParentByType('window')

      gridView.on
        itemdblclick: (view, record, el, index, event) ->
          FM.Logger.debug('WebDavConnectionList itemdblclick() called', panel, arguments)
          event.preventDefault()
          event.stopPropagation()
          event.stopEvent()
          record.initConneciton(FM.Active)
          dialog.close()

      selection.on
        selectionchange: (view, records) ->
          FM.Logger.debug('WebDavConnectionList selectionchange() called', panel, arguments)
          if records.length > 0
            Ext.ComponentQuery.query('button[cls="fm-webdav-connection-remove"]', toolbar)[0].setDisabled(false)
            Ext.ComponentQuery.query('button[cls="fm-webdav-connection-edit"]', toolbar)[0].setDisabled(false)
          else
            Ext.ComponentQuery.query('button[cls="fm-webdav-connection-remove"]', toolbar)[0].setDisabled(true)
            Ext.ComponentQuery.query('button[cls="fm-webdav-connection-edit"]', toolbar)[0].setDisabled(true)

  initGridConfig: () ->

    @setConfig
      columns: [
        {
          header: t("Host")
          dataIndex: "host"
          flex: true
          editor:
            allowBlank: false
            vtype: "host"
            maxLength: 255
          field:
            xtype: 'textfield'
            allowBlank: false
            blankText: 'webdav.domain.ru'
        },
        {
          header: t("User")
          dataIndex: "user",
          editor:
            allowBlank: false
            maxLength: 32
        },
        {
          header: t("Password")
          dataIndex: "decryptedPassword"
          renderer: (value) ->
            return value.replace(/./g, "*").substr(0, 8);
          editor:
            allowBlank: false
            maxLength: 32
        }
      ]