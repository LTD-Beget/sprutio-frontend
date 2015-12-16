Ext.define 'FM.action.Chmod',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.ChmodFilesWindow'
  ]
  config:
    iconCls: "fm-action-chmod"
    text: t("Edit Attributes")
    handler: (panel = FM.Active, records) ->
      FM.Logger.info('Run Action FM.action.Chmod', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      win = Ext.create "FM.view.windows.ChmodFilesWindow",
        taskBar: bottom_toolbar
        chmod: (button, chmod_window, e, params) =>

          wait = Ext.create 'FM.view.windows.ProgressWindow',
            cancelable: true
            msg: t("Applying attributes, please wait...")
            cancel: (wait_window, session, status) ->
              FM.Logger.debug('Chmod cancel called()', arguments)
              if status?
                FM.Actions.Chmod.cancel(wait_window, session, status)

          wait.setSession(session)
          FM.Actions.Chmod.process(wait, session, params)
          chmod_window.close()

      win.setSession(session)
      win.initRecords(records)
      win.show()

  process: (progress_window, session, params, status) ->
    FM.Logger.debug('FM.action.Chmod process() called = ', arguments)

    if status?
      if status.status? and (status.status == FM.Status.STATUS_RUNNING or status.status == FM.Status.STATUS_WAIT)
        setTimeout () =>
          FM.backend.ajaxSend '/actions/main/check_status',
            params:
              session: session
              status: status
            success: (response) =>
              status = Ext.util.JSON.decode(response.responseText).data

              if status.progress? and (status.progress.text? or status.progress.percent?)
                text = if status.progress.text? then status.progress.text else ''
                percent = if status.progress.percent? then status.progress.percent else 0
                progress_window.updateProgress(percent, text)
              else
                progress_window.updateProgressText(t("Estimating operation length..."))

              @process(progress_window, session, params, status)

            failure: (response) =>
              FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
              FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.file.chmodFiles, status, session, progress_window, params)
    else
      if session.type == FM.Session.LOCAL_APPLET
        try
          FM.Active.applet.chmod(progress_window, session, params)
        catch
          FM.Logger.error("Applet error")
          FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      else
        FM.backend.ajaxSend '/actions/files/chmod',
          params:
            session: session
            params: params
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data
            progress_window.setOperationStatus(status)
            progress_window.show()
            @process(progress_window, session, params, status)

          failure: (response) =>
            FM.Logger.debug(response)

            FM.helpers.ShowError(t("Error during chmod files operation start. Please contact Support."))
            FM.Logger.error(response)

  cancel: (progress_window, session, status) ->
    FM.backend.ajaxSend '/actions/main/cancel_operation',
      params:
        session: session
        status: status
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        FM.Logger.debug(response_data)
        progress_window.close()

      failure: (response) =>
        progress_window.close()
        FM.helpers.ShowError(t("Error during chmod operation aborting. Please contact Support."))
        FM.Logger.error(response)