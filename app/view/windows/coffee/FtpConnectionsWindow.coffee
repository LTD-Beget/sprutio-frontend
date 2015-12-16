Ext.define 'FM.view.windows.FtpConnectionsWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.grids.ConnectionList'
  ]
  alias: 'widget.ftp-connections-window'
  title: t("External FTP")
  cls: 'fm-ftp-connections-window'
  animate: true
  constrain: true
  layout: 'fit'
  bodyPadding: '0 0 20 0'
  width: 450
  height: 300
  resizable:
    handles: 's n e w se'
    minHeight: 300
    maxHeight: 900
    pinned: true
  maximizable: true
  modal: false
  border: false
  items: [
    {
      xtype: 'connection-list'
    }
  ]
  initComponent: () ->
    FM.Logger.debug('FM.view.windows.FtpConnectionsWindow initComponent() called', arguments)
    @callParent(arguments)