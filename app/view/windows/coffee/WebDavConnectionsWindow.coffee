Ext.define 'FM.view.windows.WebDavConnectionsWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.grids.WebDavConnectionList'
  ]
  alias: 'widget.webdav-connections-window'
  title: t("External WebDav")
  cls: 'fm-webdav-connections-window'
  animate: true
  constrain: true
  layout: 'fit'
  bodyPadding: '0 0 20 0'
  width: 550
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
      xtype: 'webdav-connection-list'
    }
  ]
  initComponent: () ->
    FM.Logger.debug('FM.view.windows.WebDavConnectionsWindow initComponent() called', arguments)
    @callParent(arguments)