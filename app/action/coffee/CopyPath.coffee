Ext.define 'FM.action.CopyPath',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-copy-path"
    text: t("Current Path")
    handler: (panel = FM.Active) ->
      FM.Logger.info('Run Action FM.action.CopyPath', arguments)

      record = FM.helpers.GetLastSelected(panel)

      if record
        if record.get('name') == '..'
          FM.helpers.CopyToClipboard(panel.session.path)
        else
          FM.helpers.CopyToClipboard(FM.helpers.GetAbsName(panel.session, record))
      else
        FM.helpers.CopyToClipboard(panel.session.path)