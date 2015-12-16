Ext.define 'FM.action.DownloadArchive',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.action.DownloadZip'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-download-archive"
    text: t("Download Archive")
    handler: (panel, records) ->
      FM.Logger.info('Run Action FM.action.DownloadArchive', arguments)
      FM.Actions.DownloadZip.execute(panel, records)