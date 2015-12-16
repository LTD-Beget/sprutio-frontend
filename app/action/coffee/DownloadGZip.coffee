Ext.define 'FM.action.DownloadGZip',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-download-gzip"
    text: t("Download as TAR.GZ archive")
    handler: (panel, records) ->
      FM.Logger.info('handler DownloadGZip action()', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      paths = FM.helpers.GetAbsNames(session, records)

      FM.backend.ajaxSubmit '/actions/files/download',
        params:
          session: Ext.JSON.encode(session)
          mode: 'gzip'
          paths: Ext.JSON.encode(paths)