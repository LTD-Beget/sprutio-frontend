Ext.define 'FM.action.Up',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-up"
    tooltip: t("Level Up")
    handler: (path, panel) ->
      FM.Logger.info('Run Action FM.action.Up', path, panel)
      FM.getApplication().fireEvent(FM.Events.file.openDirectory, panel.session, FM.helpers.GetParentPath(panel.session, path), [panel])