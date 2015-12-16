Ext.define 'FM.action.AnalyzeSize',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.AnalyzeSizeWindow'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-analyze-size"
    text: t("Analyze Size")
    handler: (panel = FM.Active, path = FM.Active.session.path) ->
      FM.Logger.info('Run Action FM.action.AnalyzeSize', arguments)

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      FM.Logger.debug('session is', session, panel)

      win = Ext.create "FM.view.windows.AnalyzeSizeWindow",
        taskBar: bottom_toolbar

      win.setPath(path)
      win.setSession(session)
      win.show()

      FM.Actions.AnalyzeSize.process(win, session)

  process: (chart_window, session, status) ->
    FM.Logger.debug('FM.action.AnalyzeSize process() called = ', arguments)

    files_list = Ext.ComponentQuery.query("file-size-list", chart_window)[0]
    files_chart = Ext.ComponentQuery.query("file-size-chart", chart_window)[0]

    if status?
      if status.status? and (status.status == FM.Status.STATUS_RUNNING or status.status == FM.Status.STATUS_WAIT)
        setTimeout () =>
          FM.backend.ajaxSend '/actions/main/check_status',
          params:
            session: session
            status: status
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data
            @process(chart_window, session, status)

          failure: (response) =>
            FM.helpers.UnsetLoading(files_list.body)
            FM.helpers.UnsetLoading(files_chart)
            FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
            FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.file.analyzeSize, status, session, chart_window)
    else
      if session.type == FM.Session.LOCAL_APPLET
        try
          FM.Active.applet.analyze_size(chart_window, session)
        catch
          FM.Logger.error("Applet error")
          FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      else
        FM.helpers.SetLoading(files_list.body, t("Retrieve folders and files size..."))
        FM.helpers.SetLoading(files_chart, t("Retrieve folders and files size..."))

        FM.backend.ajaxSend '/actions/files/analyze_size',
          params:
            session: session
            path: chart_window.getPath()
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data
            chart_window.setOperationStatus(status)
            @process(chart_window, session, status)

          failure: (response) =>
            FM.helpers.UnsetLoading(files_list.body)
            FM.helpers.UnsetLoading(files_chart)
            FM.Logger.debug(response)
            FM.helpers.ShowError(t("Error during size analysis operation start.<br/>Please contact Support."))
            FM.Logger.error(response)