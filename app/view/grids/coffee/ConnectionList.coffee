Ext.define 'FM.view.grids.ConnectionList',
  extend: 'Ext.grid.Panel'
  alias: 'widget.connection-list'
  cls: 'fm-connection-list'
  columns: []
  stateful: true   ## <-- ???
  multiSelect: false
  tbar:
    xtype: 'connection-list-top-toolbar'
  viewConfig:
    stripeRows: false
  plugins: [
    Ext.create "Ext.ux.grid.plugin.RowEditing",
      clicksToMoveEditor: 1
      clicksToEdit: 0
      autoCancel: true
  ]
  requires: [
    'FM.view.toolbars.ConnectionListTopToolbar'
    'FM.model.FtpConnection'

    'Ext.ux.grid.plugin.RowEditing'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.grids.ConnectionList init')
    @callParent(arguments)

    @initGridConfig()
    @initHandlers()

    @setStore(FM.Stores.FtpConenctions)

  initHandlers: () ->
    panel = @

    do (panel) ->
      gridView = panel.getView()
      selection = gridView.getSelectionModel()

      toolbar  = Ext.ComponentQuery.query('connection-list-top-toolbar', panel)[0]
      dialog = toolbar.findParentByType('window')

      gridView.on
        itemdblclick: (view, record, el, index, event) ->
          FM.Logger.debug('ConnectionList itemdblclick() called', panel, arguments)
          event.preventDefault()
          event.stopPropagation()
          event.stopEvent()
          record.initConneciton(FM.Active)
          dialog.close()

      selection.on
        selectionchange: (view, records) ->
          FM.Logger.debug('ConnectionList selectionchange() called', panel, arguments)
          if records.length > 0
            Ext.ComponentQuery.query('button[cls="fm-connection-remove"]', toolbar)[0].setDisabled(false)
            Ext.ComponentQuery.query('button[cls="fm-connection-edit"]', toolbar)[0].setDisabled(false)
          else
            Ext.ComponentQuery.query('button[cls="fm-connection-remove"]', toolbar)[0].setDisabled(true)
            Ext.ComponentQuery.query('button[cls="fm-connection-edit"]', toolbar)[0].setDisabled(true)

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
            blankText: 'ftp.domain.ru'
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