Ext.define 'FM.action.Root',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-root"
    tooltip: t("File Root")
    handler: (panel) ->
      FM.Logger.info('Run Action FM.action.Root', panel)
      FM.getApplication().fireEvent(FM.Events.file.openDirectory, panel.session, FM.helpers.GetRootPath(panel.session), [panel])