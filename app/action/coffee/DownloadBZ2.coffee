Ext.define 'FM.action.DownloadBZ2',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-download-bz2"
    text: t("Download as BZip2 archive")
    handler: (panel, records) ->
      FM.Logger.info('Run Action FM.action.DownloadBZ2', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      paths = FM.helpers.GetAbsNames(session, records)

      FM.backend.ajaxSubmit '/actions/files/download',
        params:
          session: Ext.JSON.encode(session)
          mode: 'bz2'
          paths: Ext.JSON.encode(paths)