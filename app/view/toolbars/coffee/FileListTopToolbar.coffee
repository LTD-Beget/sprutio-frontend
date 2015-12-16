Ext.define 'FM.view.toolbars.FileListTopToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.file-list-top-toolbar'
  cls: 'fm-file-list-top-toolbar'
  items: []
  requires: [
    'Ext.ux.container.SwitchButtonSegment'
    'FM.view.toolbars.FileListPathBar'
  ]
  height: 40
  defaults:
    margin: 0
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.FileListTopToolbar')

    @items = []

    @items.push
      xtype: 'button'
      text: t("Home FTP")
      iconCls: "fm-action-home"
      cls: 'fm-source-button'
      margin: '0 10 0 0'
      menu:
        xtype: 'menu'
        items: [
          {
            text: FM.Actions.HomeFtp.getMenuText()
            iconCls: FM.Actions.HomeFtp.getIconCls()
            handler: () ->
              FM.Actions.HomeFtp.execute(FM.Active)
          },
          {
            text: FM.Actions.Local.getMenuText()
            iconCls: FM.Actions.Local.getIconCls()
            handler: () ->
              FM.Actions.Local.execute(FM.Active)
          },
          {
            text: FM.Actions.RemoteFtp.getMenuText()
            iconCls: FM.Actions.RemoteFtp.getIconCls()
            handler: () ->
              FM.Actions.RemoteFtp.execute(FM.Active)
          }
        ]

    segment = Ext.create "Ext.ux.container.SwitchButtonSegment",
      activeItem: 0
      hidden: true
      items: [
        {
          cls: 'fm-grid-view'
          viewMode: "default"
          iconCls: "fm-view-default"
        },
        {
          cls: 'fm-grid-view'
          viewMode: "tileIcons"
          iconCls: "fm-view-tile"
        },
        {
          cls: 'fm-grid-view'
          viewMode: "mediumIcons"
          iconCls: "fm-view-medium"
        },
        {
          cls: 'fm-grid-view'
          viewMode: "largeIcons"
          iconCls: "fm-view-large"
        }
      ]
      listeners:
        change: (btn) =>
          panel = @ownerCt
          FM.Logger.debug('change', arguments, panel)
          # TODO Implement Mode Change
          panel.filelist.getView().focus()

    @items.push FM.Actions.Root
    @items.push FM.Actions.Up

    @items.push
      xtype: 'file-list-path-bar'

    @items.push "->"
    @items.push segment

    @callParent(arguments);