Ext.define 'FM.action.Open',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-open"
    text: t("Open")
    handler: (panel, path) ->
      FM.Logger.info('Run Action FM.action.Open', panel, path)
      FM.getApplication().fireEvent(FM.Events.file.openDirectory, panel.session, path, [panel])