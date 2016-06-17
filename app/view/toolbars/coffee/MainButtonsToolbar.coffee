Ext.define 'FM.view.toolbars.MainButtonsToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.main-buttons-toolbar'
  id: "fm-main-buttons-toolbar"
  border: false
  overflowX: 'auto'
  overflowY: 'hidden'
  style:
    borderStyle: 'none'
  items: []
  requires: [
    'Ext.container.ButtonGroup'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.MainButtonsToolbar init')

    @items = []
    @items.push
      xtype: "buttongroup"
      frame: true
      bodyBorder: true
      height: 80
      items: [
          {
            xtype: 'button'
            name: FM.Actions.HomeFtp.getIconCls()
            text: FM.Actions.HomeFtp.getMenuText()
            iconCls: FM.Actions.HomeFtp.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.HomeFtp.execute(FM.Active)
          },
          {
            xtype: 'button'
            name: FM.Actions.RemoteConnections.getIconCls()
            text: FM.Actions.RemoteConnections.getMenuText()
            iconCls: FM.Actions.RemoteConnections.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.RemoteConnections.execute(FM.Active)
          },
          {
            xtype: 'button'
            name: FM.Actions.Refresh.getIconCls()
            text: FM.Actions.Refresh.getMenuText()
            iconCls: FM.Actions.Refresh.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.Refresh.execute([FM.Left, FM.Right])
          },
          {
            xtype: 'button'
            name: FM.Actions.NewFolder.getIconCls()
            text: FM.Actions.NewFolder.getMenuText()
            iconCls: FM.Actions.NewFolder.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.NewFolder.execute(FM.Active)
          },
          {
            xtype: 'button'
            name: FM.Actions.Upload.getIconCls()
            text: FM.Actions.Upload.getMenuText()
            iconCls: FM.Actions.Upload.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.Upload.execute()
          },
          {
            xtype: 'button'
            name: FM.Actions.CreateArchive.getIconCls()
            text: FM.Actions.CreateArchive.getMenuText()
            iconCls: FM.Actions.CreateArchive.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () ->
              records = FM.helpers.GetSelected(FM.Active)
              FM.Actions.CreateArchive.execute(FM.Active, records)
          },
          {
            xtype: 'button'
            name: FM.Actions.DownloadArchive.getIconCls()
            text: FM.Actions.DownloadArchive.getMenuText()
            iconCls: FM.Actions.DownloadArchive.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              records = FM.helpers.GetSelected(FM.Active)
              FM.Actions.DownloadArchive.execute(FM.Active, records)
          },
          {
            xtype: 'button'
            name: FM.Actions.SearchFiles.getIconCls()
            text: FM.Actions.SearchFiles.getMenuText()
            iconCls: FM.Actions.SearchFiles.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.SearchFiles.execute(FM.Active)
          },
          {
            xtype: 'button'
            name: FM.Actions.SearchText.getIconCls()
            text: FM.Actions.SearchText.getMenuText()
            iconCls: FM.Actions.SearchText.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.SearchText.execute(FM.Active)
          },
          {
            xtype: 'button'
            name: FM.Actions.AnalyzeSize.getIconCls()
            text: FM.Actions.AnalyzeSize.getMenuText()
            iconCls: FM.Actions.AnalyzeSize.getIconCls()
            scale: 'large'
            iconAlign: 'top'
            handler: () =>
              FM.Actions.AnalyzeSize.execute(FM.Active, FM.Active.session.path)
          }
      ]

    @callParent(arguments);