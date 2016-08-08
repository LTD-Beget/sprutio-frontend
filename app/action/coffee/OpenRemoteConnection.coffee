Ext.define 'FM.action.OpenRemoteConnection',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-open-ftp"
    text: t("Open")
    handler: (panel, session) ->
      FM.Logger.info('Run Action FM.action.OpenRemoteConnection', panel, session)

      FM.helpers.SetLoading(panel.body, t("Loading..."))
      FM.backend.ajaxSend '/actions/main/init_session',
        params:
          session: session
        success: (response) ->
          response_data = Ext.util.JSON.decode(response.responseText).data

          listing = response_data.listing

          if listing.path != '/'
            listing.items.unshift
              name: ".."
              is_dir: true

          FM.getApplication().fireEvent(FM.Events.main.initSession, response_data, [panel])
        failure: (response) ->
          FM.helpers.UnsetLoading(panel.body)
          FM.Logger.debug(response)
          FM.helpers.ShowError(t("Unable to open connection.<br/> Check credentials and try again."))
          FM.Logger.error(response)
