Ext.define 'FM.view.grids.IPBlockList',
  extend: 'Ext.grid.Panel'
  alias: 'widget.ip-block-list'
  cls: 'fm-ip-block-list'
  columns: []
  stateful: true, ## <-- ???
  multiSelect: true
  enableColumnHide: false
  enableColumnMove: false
  tbar:
    xtype: 'ip-block-list-top-toolbar'
  viewConfig:
    stripeRows: false
  requires: [
    'FM.view.toolbars.IPBlockListTopToolbar'
    'FM.model.IP'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.grids.IPBlockList init')

    plugin = Ext.create "Ext.ux.grid.plugin.RowEditing",
      clicksToMoveEditor: 1
      autoCancel: false

    @plugins = [plugin]
    @callParent(arguments)

    @initGridConfig()
    @initHandlers()
    @initGridStore()

  initHandlers: () ->
    panel = @

    do (panel) ->
      selection = panel.getView().getSelectionModel()
      toolbar  = Ext.ComponentQuery.query('ip-block-list-top-toolbar', panel)[0]

      selection.on
        selectionchange: (view, records) ->
          FM.Logger.debug('FileList selectionchange() called', panel, arguments)
          if records.length > 0
            Ext.ComponentQuery.query('button[cls="fm-ip-remove"]', toolbar)[0].setDisabled(false)
            Ext.ComponentQuery.query('button[cls="fm-ip-edit"]', toolbar)[0].setDisabled(false)
          else
            Ext.ComponentQuery.query('button[cls="fm-ip-remove"]', toolbar)[0].setDisabled(true)
            Ext.ComponentQuery.query('button[cls="fm-ip-edit"]', toolbar)[0].setDisabled(true)

  initGridConfig: () ->
    @setConfig
      columns: [
        {
          header: t("IP")
          dataIndex: "ip"
          flex: true
          editor:
            allowBlank: false
            regex: /^([\d]{0,3}[\.]?)?([\d]{0,3}[\.]?)?([\d]{0,3}[\.]?)?([\d]{0,3}[\.]?)?[\/]?([\d]{0,3}[\.]?)?([\d]{0,3}[\.]?)?([\d]{0,3}[\.]?)?([\d]{0,3})?$/,
            regexText: t("Incorrect ip value")
            maxLength: 255
        },
        {
          header: t("Comment"),
          dataIndex: "comment",
          flex: true,
          editor:
            allowBlank: true
            maxLength: 255
        }
      ]

  initGridStore: () ->
    store = Ext.create "Ext.data.Store",
      sortOnLoad: true
      model: 'FM.model.IP'

    @setStore(store)