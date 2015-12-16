Ext.define 'FM.action.DownloadTar',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-download-tar"
    text: t("Download as TAR archive")
    handler: (panel, records) ->
      FM.Logger.info('Run Action FM.action.DownloadTar', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      paths = FM.helpers.GetAbsNames(session, records)

      FM.backend.ajaxSubmit '/actions/files/download',
        params:
          session: Ext.JSON.encode(session)
          mode: 'tar'
          paths: Ext.JSON.encode(paths)