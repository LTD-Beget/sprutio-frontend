Ext.define 'FM.action.RemoteConnections',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.ConnectionsWindow'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-remote"
    text: t("Remote server")
    handler: () ->
      FM.Logger.info('Run Action FM.action.RemoteConnections', arguments)

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]

      win = Ext.create "FM.view.windows.ConnectionsWindow",
        taskBar: bottom_toolbar

      win.show()