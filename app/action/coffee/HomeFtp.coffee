Ext.define 'FM.action.HomeFtp',
  extend: 'FM.overrides.Action'
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-home"
    text: t("Home server")
    handler: (panel) ->
      FM.Logger.info('Run Action FM.action.HomeFtp', arguments)

      FM.helpers.SetLoading(panel.body, t("Loading..."))
      FM.backend.ajaxSend '/actions/main/init_session',
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          FM.getApplication().fireEvent(FM.Events.main.initSession, response_data, [panel])
        error: () =>
          FM.helpers.UnsetLoading(panel.body)