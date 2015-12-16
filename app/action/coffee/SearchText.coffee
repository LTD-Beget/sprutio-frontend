Ext.define 'FM.action.SearchText',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.grids.FileSearchList'
    'FM.view.forms.SearchTextForm'
    'FM.view.windows.SearchTextWindow'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-search-text"
    text: t("Search Text")
    handler: (panel = FM.Active) ->
      FM.Logger.info('Run Action FM.action.SearchText', arguments)

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      win = Ext.create "FM.view.windows.SearchTextWindow",
        taskBar: bottom_toolbar
        taskBar: bottom_toolbar
        search: (button, search_window, e, params) =>

          search_window.cancel_btn.setVisible(true)
          button.setVisible(false)
          files_list = Ext.ComponentQuery.query("file-search-list", search_window)[0]
          FM.helpers.SetLoading(files_list, t("Loading search result..."))
          FM.Actions.SearchText.process(button, search_window, search_window.getSession(), params, files_list)

        cancel: (button, search_window, e, status) =>
          FM.Logger.info('aborting search files', arguments)
          files_list = Ext.ComponentQuery.query("file-search-list", search_window)[0]
          FM.Actions.SearchText.cancel(button, search_window, search_window.getSession(), status, files_list)

      win.setSession(session)
      win.show()

  process: (button, search_window, session, params, files_list, status) ->
    FM.Logger.debug('FM.action.SearchText process() called = ', arguments)

    if status?
      if status.status? and (status.status == FM.Status.STATUS_RUNNING or status.status == FM.Status.STATUS_WAIT)
        setTimeout () =>
          FM.backend.ajaxSend '/actions/main/check_status',
          params:
            session: session
            status: status
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data
            @process(button, search_window, session, params, files_list, status)

          failure: (response) =>
            json_response = Ext.util.JSON.decode(response.responseText)
            error = FM.helpers.ParseErrorMessage(json_response.message, t("Error during check operation status.<br/>Please contact Support."))
            FM.helpers.ShowError(error)
            FM.Logger.error(response)

            button.setVisible(false)
            search_window.search_btn.setVisible(true)
            FM.helpers.UnsetLoading(files_list)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.Logger.debug('ready to fire event FM.Events.search.findText', status, session, search_window, files_list)
        FM.getApplication().fireEvent(FM.Events.search.findText, status, session, search_window, files_list)
    else
      if session.type == FM.Session.LOCAL_APPLET
        try
          FM.Active.applet.search_files(button, search_window, session, params, files_list)
        catch
          FM.Logger.error("Applet error")
          FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      else
        FM.backend.ajaxSend '/actions/find/text',
          params:
            session: session
            params: params
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data
            search_window.setOperationStatus(status)
            @process(button, search_window, session, params, files_list, status)

          failure: (response) =>
            FM.Logger.debug(response)

            search_window.cancel_btn.setVisible(false)
            button.setVisible(true)
            FM.helpers.UnsetLoading(files_list)

            FM.helpers.ShowError(t("Error during text searching operation start.<br/> Please contact Support."))
            FM.Logger.error(response)

  cancel: (button, search_window, session, status, files_list) ->
    FM.Logger.debug('FM.action.SearchText cancel() called = ', arguments)

    if status?
      FM.backend.ajaxSend '/actions/main/cancel_operation',
        params:
          session: session
          status: status
        success: () ->
          #pass

        failure: (response) ->
          button.setVisible(false)
          search_window.search_btn.setVisible(true)
          FM.helpers.ShowError(t("Error during abortion of text searching operation.<br/> Please contact Support."))
          FM.Logger.error(response)

    else
      button.setVisible(false)
      search_window.search_btn.setVisible(true)
      FM.helpers.UnsetLoading(files_list)