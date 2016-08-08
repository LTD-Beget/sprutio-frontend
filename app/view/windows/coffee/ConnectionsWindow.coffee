Ext.define 'FM.view.windows.ConnectionsWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.grids.ConnectionList'
  ]
  alias: 'widget.connections-window'
  title: t("Remote server")
  cls: 'fm-connections-window'
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
      xtype: 'connection-list'
    }
  ]
  initComponent: () ->
    FM.Logger.debug('FM.view.windows.ConnectionsWindow initComponent() called', arguments)
    @callParent(arguments)