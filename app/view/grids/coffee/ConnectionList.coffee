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
      listeners: {
        beforeEdit: (boundEl, value) ->
          # если это соединение уже редактировалось, то его тип нельзя изменять
          if value.record.get('id') > 0
            boundEl.editor.getComponent('combobox-connection-type-component').disable()
          else
            boundEl.editor.getComponent('combobox-connection-type-component').enable()
      }
  ]
  requires: [
    'FM.view.toolbars.ConnectionListTopToolbar'
    'FM.model.Connection'

    'Ext.ux.grid.plugin.RowEditing'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.grids.ConnectionList init')
    @callParent(arguments)

    @initGridConfig()
    @initHandlers()

    @setStore(FM.Stores.Conenctions)

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
          record.initConnection(FM.Active)
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
          header: t("Type")
          dataIndex: "type"
          maxWidth: 80
          align: 'center'
          renderer: (value) ->
            return '<img align="left" src="fm/resources/images/icons/16/' + value + '.png">' + value.toUpperCase();
          editor:
            id: 'combobox-connection-type-component'
            xtype: 'combobox'
            listeners: {
              change: () ->
                port = Ext.getCmp('port-cell-id-for-finding-in-combobox-change-func')
                if @getValue() == 'sftp' and port.value == '21'
                  port.setValue('22')
                if @getValue() == 'ftp' and port.value == '22'
                  port.setValue('21')
            }
            editable: false
            triggerAction: 'all'
            allowBlank: false
            valueField: 'value'
            displayField: 'display'
            store: Ext.create('Ext.data.Store', {
              fields:[
                'display'
                'value'
              ]
              data:[
                {
                  display: 'ftp'
                  value: 'ftp'
                }
                {
                  display: 'sftp'
                  value: 'sftp'
                }
              ]
            })
        },
        {
          header: t("Host")
          dataIndex: "host"
          flex: true
          editor:
            allowBlank: false
            maxLength: 255
        },
        {
          header: t("Port")
          dataIndex: "port"
          maxWidth: 55
          editor:
            id: 'port-cell-id-for-finding-in-combobox-change-func'
            allowBlank: false
            maxLength: 5
        },
        {
          header: t("User")
          dataIndex: "user"
          flex: true
          editor:
            allowBlank: false
            maxLength: 32
        },
        {
          header: t("Password")
          dataIndex: "decryptedPassword"
          flex: true
          renderer: (value) ->
            return value.replace(/./g, "*").substr(0, 8);
          editor:
            allowBlank: false
            maxLength: 64
        }
      ]