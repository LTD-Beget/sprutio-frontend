Ext.define 'FM.action.DownloadBasic',
  extend: 'FM.overrides.Action'
  requires: [
    'Ext.form.action.StandardSubmit'
  ]
  config:
    iconCls: "fm-action-download-basic"
    text: t("Basic Download (file)")
    handler: (panel, record) ->
      FM.Logger.info('Run Action FM.action.DownloadBasic', arguments)

      if !record? or record.get('is_dir')
        FM.helpers.ShowError(t("Please select file(not a directory) entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      path = FM.helpers.GetAbsName(session, record)

      FM.backend.ajaxSubmit '/actions/files/download',
        params:
          session: Ext.JSON.encode(session)
          mode: 'default'
          paths: Ext.JSON.encode([path])