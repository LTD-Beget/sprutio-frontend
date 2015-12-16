Ext.define 'FM.action.IPBlock',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.IPBlockWindow'
  ]
  config:
    iconCls: "fm-action-ip-block"
    text: t("Block Access by IP address")
    handler: (panel) ->
      FM.Logger.info('Run Action FM.action.IPBlock', arguments)

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      wait = Ext.create 'FM.view.windows.ProgressWindow',
        cancelable: false
        msg: t("Retrieving settings, please wait...")

      wait.show()

      FM.backend.ajaxSend '/actions/htaccess/read_rules',
        params:
          session: session
          path: session.path
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          wait.close()

          win = Ext.create "FM.view.windows.IPBlockWindow",
            taskBar: bottom_toolbar
            save: (button, ip_window, e, params) ->
              button.disable()
              FM.Logger.debug('save handler()', arguments)
              FM.backend.ajaxSend '/actions/htaccess/save_rules',
                params:
                  session: session
                  path: session.path
                  params: params
                success: (response) =>
                  button.enable()
                  response_data = Ext.util.JSON.decode(response.responseText).data
                  ip_window.setRules(response_data)

                  FM.helpers.ApplySession session, (panel) ->
                    panel.filelist.clearListCache()

                    # Update grids if same path
                    if panel.session.path == session.path
                      FM.Actions.Refresh.execute([panel])

                failure: (response) =>
                  FM.helpers.ShowError(t("Error during saving ip rules.<br/> Please contact Support."))
                  button.enable()
                  FM.Logger.error(response)

          win.setSession(session)
          win.setRules(response_data)
          win.show()

        failure: (response) =>
          wait.close()
          FM.helpers.ShowError(t("Error during retrieving ip block settings.<br/> Please contact Support."))
          FM.Logger.error(response)