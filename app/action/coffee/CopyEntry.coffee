Ext.define 'FM.action.CopyEntry',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-copy-entry"
    text: t("Current File")
    handler: (panel = FM.Active) ->
      FM.Logger.info('Run Action FM.action.CopyEntry', arguments)
      record = FM.helpers.GetLastSelected(panel)

      if record? and record.get('name') != '..'
        FM.helpers.CopyToClipboard(record.get('name'))
      else
        FM.helpers.ShowError(t("Please select file entry."))