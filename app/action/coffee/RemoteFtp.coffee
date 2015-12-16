Ext.define 'FM.action.RemoteFtp',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.FtpConnectionsWindow'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-remote"
    text: t("Remote FTP")
    handler: () ->
      FM.Logger.info('Run Action FM.action.RemoteFtp', arguments)

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]

      win = Ext.create "FM.view.windows.FtpConnectionsWindow",
        taskBar: bottom_toolbar

      win.show()