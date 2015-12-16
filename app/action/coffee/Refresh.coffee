Ext.define 'FM.action.Refresh',
  extend: 'FM.overrides.Action'
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-refresh"
    text: t("Refresh")
    handler: (panels = [FM.Left, FM.Right]) ->

      FM.Logger.info('Run Action FM.action.Refresh', arguments)

      for panel in panels
        do (panel) ->
          FM.Logger.info("Refreshing ", panel)
          FM.helpers.SetLoading(panel.body, t("Loading..."))

          if !panel.session?
            panel.session = {
              type: FM.Session.HOME,
              path: "/"
            }

          if panel.session.type == FM.Session.LOCAL_APPLET
            try
              panel.applet.listdir(panel.session.path, panel.toString())
            catch
              FM.helpers.ShowError(t("Error during operation. Please contact Support."))
              FM.helpers.UnsetLoading(panel.body)
          else
            FM.backend.ajaxSend '/actions/main/init_session',
              params:
                session: panel.session
              success: (response) ->
                response_data = Ext.util.JSON.decode(response.responseText).data
                listing = response_data.listing

                if listing.path != '/'
                  listing.items.unshift
                    name: ".."
                    is_dir: true

                FM.Logger.info("Start event ", panel)
                FM.getApplication().fireEvent(FM.Events.main.initSession, response_data, [panel])
              error: () ->
                FM.helpers.ShowError(t("Error during operation. Please contact Support."))
                FM.helpers.UnsetLoading(panel.body)